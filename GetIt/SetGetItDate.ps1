# Writes the date shown by the GetIt Package Manager for a locally installed package.
#
# GetIt paints the VersionTimestamp value of the package, and that field is not part of
# the local JSON format: for a package installed with "Load Local Package" GetIt always
# stores its built-in default and the list shows "1 Jan 2000". The Modified field of the
# JSON is read correctly but is not what the UI displays.
#
# This script copies the Modified value of the JSON into VersionTimestamp (and Modified)
# on both the package key and the Versions\<Version> subkey. Run it with RAD Studio
# closed, after every local install of the package - GetIt rewrites those keys each time.

[CmdletBinding()]
param(
    [string] $JsonPath = (Join-Path $PSScriptRoot 'CWStudioComponents.json'),
    [string] $ProductVersion = '37.0'
)

$ErrorActionPreference = 'Stop'

if (Get-Process bds, bds64 -ErrorAction SilentlyContinue) {
    throw 'RAD Studio is running. Close the IDE first, it rewrites these registry values on exit.'
}

if (-not (Test-Path $JsonPath)) { throw "JSON not found: $JsonPath" }
$json = Get-Content $JsonPath -Raw | ConvertFrom-Json

$version = $json.Version
if (-not $version) { throw 'The JSON has no Version field.' }

# GetIt splits Id at the last dash: everything before it is the package id, which is also
# the registry key name and the folder name under the catalog repository.
$packageId = $json.PackageId
if (-not $packageId) {
    $packageId = $json.Id
    $dash = $packageId.LastIndexOf('-')
    if ($dash -gt 0) { $packageId = $packageId.Substring(0, $dash) }
}

$modified = $json.Modified
if (-not $modified) { throw 'The JSON has no Modified field.' }
# InvariantCulture matters: in a format string "-" and ":" are culture separators, so on a
# Polish locale "yyyy-MM-dd" would expect "2026.09.10".
[string[]] $formats = @('yyyy-MM-dd HH:mm:ss', 'yyyy-MM-dd')
$date = [datetime]::ParseExact($modified, $formats,
    [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None)

$root = "HKCU:\Software\Embarcadero\BDS\$ProductVersion\CatalogRepository\Packages\$packageId"
if (-not (Test-Path $root)) {
    throw "Package not installed: $root. Install it through GetIt first."
}

$bytes = [BitConverter]::GetBytes($date.ToOADate())
$keys = @($root)
$versionKey = Join-Path $root "Versions\$version"
if (Test-Path $versionKey) { $keys += $versionKey } else { Write-Warning "No version key: $versionKey" }

foreach ($key in $keys) {
    foreach ($name in 'VersionTimestamp', 'Modified') {
        Set-ItemProperty -Path $key -Name $name -Value $bytes -Type Binary
    }
    Write-Output ("{0} -> {1:yyyy-MM-dd HH:mm:ss}" -f $key.Replace('HKCU:\Software\Embarcadero\BDS\', ''), $date)
}

Write-Output 'Done. Start RAD Studio and reopen the GetIt Package Manager.'
