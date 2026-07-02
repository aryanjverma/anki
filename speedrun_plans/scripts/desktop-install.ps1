#requires -Version 5
<#
.SYNOPSIS
    Install the MCAT (Anki fork) desktop MSI.
.DESCRIPTION
    Installs the most recent MSI from out\installer\dist (or an explicit -MsiPath).
    Intended for the clean-machine install proof (FR-7): copy the MSI to a fresh
    VM and run this script there.
.PARAMETER MsiPath
    Path to the .msi to install. Defaults to the newest under out\installer\dist.
.PARAMETER Silent
    Install silently (msiexec /quiet) instead of showing the installer UI.
#>
param(
    [string]$MsiPath,
    [switch]$Silent
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path

if (-not $MsiPath) {
    $msi = Get-ChildItem "$RepoRoot\out\installer\dist\*.msi" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $msi) { throw "No MSI found. Build one first: desktop-build-installer.ps1" }
    $MsiPath = $msi.FullName
}

Write-Host "Installing: $MsiPath" -ForegroundColor Green
if ($Silent) {
    Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`" /quiet /norestart" -Wait
} else {
    Start-Process msiexec.exe -ArgumentList "/i `"$MsiPath`"" -Wait
}
Write-Host "Install finished." -ForegroundColor Green
