#requires -Version 5
<#
.SYNOPSIS
    Clean-build the MCAT (Anki fork) desktop app from source.
.DESCRIPTION
    Removes the build output dir (out/) for a true clean build, then builds and
    launches the app. Run from anywhere; the script resolves the repo root itself.
.PARAMETER NoRun
    Build only; do not launch the app afterwards.
#>
param([switch]$NoRun)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $RepoRoot
Write-Host "Repo root: $RepoRoot" -ForegroundColor Cyan
Write-Host "Commit:    $(git rev-parse HEAD)" -ForegroundColor Cyan

if (Test-Path out) {
    Write-Host "Removing out/ for a clean build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force out
}

Write-Host "Building (just build)..." -ForegroundColor Green
just build

if (-not $NoRun) {
    Write-Host "Launching (just run)..." -ForegroundColor Green
    just run
}
