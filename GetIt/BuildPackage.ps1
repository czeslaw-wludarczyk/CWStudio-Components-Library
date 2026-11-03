# Builds the GetIt payload archive CWStudioComponents-<Version>.zip from the repository root.
# The archive layout matches the relative paths used in CWStudioComponents.json:
# sources, packages and Gfx are placed at the root of the archive.
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

[CmdletBinding()]
param(
    [string] $Version = '1.9.36'
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
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zipPath

Remove-Item $staging -Recurse -Force

Write-Output "Created: $zipPath"
