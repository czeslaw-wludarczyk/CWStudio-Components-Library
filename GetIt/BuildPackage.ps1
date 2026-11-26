# Builds the GetIt payload archive CWStudioComponents-<Version>.zip from the repository root.
# The archive layout matches the relative paths used in CWStudioComponents.json:
# sources, packages and Gfx are placed at the root of the archive.
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

[CmdletBinding()]
param(
    [string] $Version = '1.9.40'
)

$ErrorActionPreference = 'Stop'

$getItDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $getItDir
$staging  = Join-Path $env:TEMP "CWStudioComponents-$Version-staging"
$zipPath  = Join-Path $getItDir "CWStudioComponents-$Version.zip"

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging | Out-Null

$files = @(
    '*.pas', '*.dpk', '*.dproj', '*.groupproj', '*.res', '*.rc', '*.dcr',
    'LICENSE', 'README.md', 'CHANGELOG.md'
)

foreach ($pattern in $files) {
    Get-ChildItem -Path $repoRoot -Filter $pattern -File -ErrorAction SilentlyContinue |
        Copy-Item -Destination $staging
}

Copy-Item -Path (Join-Path $repoRoot 'Gfx') -Destination (Join-Path $staging 'Gfx') -Recurse

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# Compress-Archive of Windows PowerShell 5.1 stores entry names with backslashes
# ("Gfx\ButtonIcon.bmp"). The ZIP specification requires forward slashes; an extractor
# that follows it creates files literally named "Gfx\ButtonIcon.bmp" in the package root
# instead of a Gfx folder, so CWStudio_Splash.rc cannot find Gfx\CWStudioSplash.bmp.
# The archive is therefore written entry by entry with "/" as the separator.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$stagingFull = (Resolve-Path $staging).Path.TrimEnd('\') + '\'
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    Get-ChildItem -Path $staging -Recurse -File | Sort-Object FullName | ForEach-Object {
        $entryName = $_.FullName.Substring($stagingFull.Length).Replace('\', '/')
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $_.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal)
    }
}
finally {
    $zip.Dispose()
}

Remove-Item $staging -Recurse -Force

Write-Output "Created: $zipPath"
