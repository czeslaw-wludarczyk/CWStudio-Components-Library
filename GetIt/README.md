# GetIt package definition — CWStudio Components 1.9.34

This folder contains everything needed to install the library through the
**Load Local Package** button of the GetIt Package Manager, and to submit the
library to Embarcadero for publication on the online GetIt catalog.

## Contents

| File | Role |
|------|------|
| `CWStudioComponents.json` | GetIt local package configuration (the file selected in the IDE) |
| `LICENSE.txt` | EULA text shown before the download; must be accepted by the user |
| `CWStudioComponents.png` | Package image displayed in the GetIt UI |
| `SetGetItDate.ps1` | Fixes the date GetIt shows for a local install (see below) |
| `BuildPackage.ps1` | Creates `CWStudioComponents-1.9.34.zip` (the package payload) |
| `CWStudioComponents-1.9.34.zip` | Payload; produced by the script, not stored in git |

## Building the payload

```powershell
powershell -ExecutionPolicy Bypass -File .\BuildPackage.ps1
```

The archive keeps the sources, the `.dpk`/`.dproj` files and the `Gfx` folder at
its root, which is what the relative paths inside the JSON expect.

## Installing locally

1. Build the payload (step above).
2. In the IDE: **Tools > GetIt Package Manager > Load Local Package**
   (requires an active Update Subscription).
3. Select `CWStudioComponents.json` and accept the license.
4. Restart the IDE when prompted.

## What the actions do

| Event (`Type`) | Action | Effect |
|----------------|--------|--------|
| 2 — After Download | `CompileProject` | Builds `CWStudio_ComponentsRT.dproj` for Win32 and Win64, Release |
| 2 — After Download | `CompileProject` | Builds `CWStudio_ComponentsDT.dproj` for Win32, Release (32-bit IDE, `bds.exe`) |
| 2 — After Download | `CompileProject` | Builds `CWStudio_ComponentsDT.dproj` for Win64, Release (64-bit IDE, `bds64.exe`) |
| 3 — Before Install | `AddOptionPath` | Adds `Win32\Release\` and `Win64\Release\` to the Delphi library path |
| 3 — Before Install | `AddOptionPath` | Adds the package root to the browsing path |
| 3 — Before Install | `InstallPackage` | Registers `$(BDSCOMMONDIR)\Bpl\CWStudio_ComponentsDT.bpl` in the 32-bit IDE |
| 3 — Before Install | `InstallPackage` | Registers `$(BDSCOMMONDIR)\Bpl\Win64\CWStudio_ComponentsDT.bpl` in the 64-bit IDE |
| 4 — After Install | `RestartIDE` | Forces a restart of the IDE at the end of the installation |
| 5 — Before Uninstall | `UninstallPackage` (x2), `RemoveOptionPath` | Reverses the installation for both IDE architectures |
| 5 — Before Uninstall | `CleanProject` (x4) | Deletes the compiled output (DCU, BPL, DCP) of `CWStudio_ComponentsDT.dproj` and `CWStudio_ComponentsRT.dproj`, one action per platform (Win32, Win64), so no build artifacts are left behind |
| 6 — After Uninstall | `RestartIDE` | Forces a restart of the IDE at the end of the uninstallation |

The `.dproj` files write DCUs to `.\$(Platform)\$(Config)` and the BPLs to the
default `$(BDSCOMMONDIR)\Bpl` for Win32 and `$(BDSCOMMONDIR)\Bpl\Win64` for
Win64, which is why the paths above are used. The 32-bit IDE (`bds.exe`) loads
the Win32 design-time BPL, the 64-bit IDE (`bds64.exe`) loads the Win64 one; the
two registrations are independent, so installing both covers either IDE.

## Dates shown in GetIt

The date displayed under the description is **not** the `Modified` field. GetIt
paints the `VersionTimestamp` value (format `d mmm yyyy`), and `VersionTimestamp`
is not part of the local file format, so GetIt always falls back to its built-in
default `2000-01-01T00:00:00Z` and the UI shows `1 Jan 2000`.

Measured on RAD Studio 13 (GetIt 7.0), reading
`HKCU\Software\Embarcadero\BDS\37.0\CatalogRepository\Packages\<PackageId>`
(both the package key and the `Versions\<Version>` subkey), where the two dates
are stored as 8-byte TDateTime values:

| JSON | Registry after install | UI |
|------|------------------------|----|
| `"Modified": "2026-09-10T00:00:00Z"` (ISO) | not parsed, field left uninitialized | `1 Jan 2000` |
| `"Modified": "2026-09-10 00:15:15"` (documented format) | `Modified` = 2026-09-10 00:15:15 | `1 Jan 2000` |
| no `VersionTimestamp` field exists locally | `VersionTimestamp` = 2000-01-01 | `1 Jan 2000` |

`Modified` still has to be right: it uses the documented `"yyyy-MM-dd HH:mm:ss"`
format (a space, not the ISO `T`/`Z` form) and drives the update detection, so it
must be bumped on every release.

An `AddValueToRegistry` action (Type 4) writing `VersionTimestamp` looks like the
obvious in-package fix, but the two actions have to be dropped: without an
`ActionId` (the form used by the official FMXLinux sample) the IDE raises an
exception in `GetItMapper.MapCatalog` while loading the JSON, and the numeric
`ActionId` of `AddValueToRegistry` is documented nowhere.

`SetGetItDate.ps1` does the same job from the outside. Run it with the IDE closed
after every local install; it copies `Modified` from the JSON into
`VersionTimestamp` on the package key and on the `Versions\<Version>` subkey:

```powershell
powershell -ExecutionPolicy Bypass -File .\SetGetItDate.ps1
```

This is only needed for local installs. On the GetIt server the field comes from
the catalog, so a published package shows the right date on its own.

## Notes for the submission to Embarcadero

The local file format is a simplified version of the server-side one. The
following fields are **not** part of the local file and have to be provided
separately when the package is registered on the GetIt server:

* **Personalities**: `delphi` (VCL only, no C++Builder support at the moment)
* **Platforms**: `Win32`, `Win64`
* **Categories**: Components / User Interface
* **Minimum and maximum product build**: RAD Studio 13 (37.0) and later
* **SKU**: all Delphi SKUs that include the VCL

Recommended hosting for the payload URL is the public GitHub release asset of
the repository, so that the `Url` field can point to a trusted location instead
of a local file.

## Hosting the package on GitHub

`CWStudioComponents-github.json` is the same definition with the `Url`,
`License` and `Image` fields pointing at GitHub instead of local files. A user
downloads that single JSON file and selects it in **Load Local Package**;
everything else is fetched over https.

What the repository has to provide:

1. **A tag and a release**, e.g. `v1.9.34`.
2. **The payload archive attached to the release** as
   `CWStudioComponents-<version>.zip`, built by `BuildPackage.ps1`. Do not use
   the "Source code (zip)" asset GitHub generates automatically: it wraps
   everything in a `CWStudioComponents-1.9.34/` top-level folder, which breaks
   every relative path used by the actions.
3. **`GetIt/LICENSE.txt` and `GetIt/CWStudioComponents.png` committed to the
   tag**, so the raw.githubusercontent.com URLs resolve. Always reference the
   tag, never `main`/`develop`, or an old JSON will start showing a newer
   license and image.
4. **`GetIt/CWStudioComponents-github.json` attached to the release too**, so
   users have a direct download link for the file they must select in the IDE.

The release is created manually with the GitHub CLI:

```powershell
git tag v1.9.34; git push origin v1.9.34
gh release create v1.9.34 .\CWStudioComponents-1.9.34.zip .\CWStudioComponents-github.json --title "CWStudio Components 1.9.34"
```

Per release, the three URLs inside the JSON have to be bumped to the new tag.

## Installation folder

GetIt unpacks the payload into
`<Documents>\Embarcadero\Studio\37.0\CatalogRepository\<Id>\<Version>`, so the
`Id` field must not contain the version: `Id` is `CWStudioComponents` and
`Version` is `1.9.34`, which gives `CWStudioComponents\1.9.34\`. Keep `Id` stable
across releases — GetIt uses it to recognize an installed package and to offer
updates; changing it makes an already installed copy invisible to the new
definition, so uninstall the old one first.
