#requires -Version 5
<#
.SYNOPSIS
    Build the MCAT (Anki fork) desktop MSI installer.
.DESCRIPTION
    Runs the release installer build (RELEASE=2) and reports the produced MSI path.
    The output MSI can then be copied to a clean machine and installed with
    desktop-install.ps1 (or a double-click).
#>
$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $RepoRoot
Write-Host "Repo root: $RepoRoot" -ForegroundColor Cyan

Write-Host "Building installer (tools\build-installer.bat, RELEASE=2)..." -ForegroundColor Green
& "$RepoRoot\tools\build-installer.bat"
if ($LASTEXITCODE -ne 0) { throw "Installer build failed (exit $LASTEXITCODE)." }

$msi = Get-ChildItem "$RepoRoot\out\installer\dist\*.msi" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($msi) {
    Write-Host "MSI built: $($msi.FullName) ($([math]::Round($msi.Length/1MB,1)) MB)" -ForegroundColor Green
} else {
    throw "Build reported success but no .msi found under out\installer\dist."
}
