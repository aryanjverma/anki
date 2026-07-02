#requires -Version 5
<#
.SYNOPSIS
    Clean-build the MCAT (Anki fork) desktop app from source.
.DESCRIPTION
    Cleans build outputs and rebuilds. By default it PRESERVES the downloaded
    toolchain (out\extracted, out\pyenv, and the out\node_modules junction) so the
    rebuild is fast and reliable -- this mirrors Anki's `just clean keep-env`.

    IMPORTANT (Windows): out\node_modules is a *junction* to the repo-root
    node_modules. Deleting all of out\ breaks that junction, and because the root
    node_modules still exists the build won't recreate it -> the build then fails
    with missing tsx.cmd/sass.cmd/jquery/mathjax. This script avoids that: the
    default keeps the junction, and -Full removes BOTH out\ and root node_modules
    so the build's own link step recreates the junction cleanly.

    For the *truest* clean-build proof, build from a fresh `git clone` instead
    (no pre-existing toolchain, so none of the above applies).
.PARAMETER Full
    Nuke the entire out\ AND the repo-root node_modules, forcing a full toolchain
    re-download + reinstall (slow; only needed if the toolchain itself is corrupt).
.PARAMETER NoRun
    Build only; do not launch the app afterwards.
#>
param(
    [switch]$Full,
    [switch]$NoRun
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $RepoRoot
Write-Host "Repo root: $RepoRoot" -ForegroundColor Cyan
Write-Host "Commit:    $(git rev-parse HEAD)" -ForegroundColor Cyan

function Test-Junction($path) {
    $item = Get-Item $path -Force -ErrorAction SilentlyContinue
    return $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

if ($Full) {
    Write-Host "FULL clean: removing out\ and root node_modules (forces reinstall)..." -ForegroundColor Yellow
    if (Test-Path out)          { Remove-Item out -Recurse -Force }
    if (Test-Path node_modules) { Remove-Item node_modules -Recurse -Force }
    # The build's link_node_modules will recreate the out\node_modules junction.
}
elseif (Test-Path out) {
    # Keep the downloaded toolchain; clean everything else so source rebuilds.
    $keep = @('extracted', 'pyenv', 'node_modules')
    Write-Host "Cleaning out\ (keeping: $($keep -join ', '))..." -ForegroundColor Yellow
    Get-ChildItem out -Force | Where-Object { $keep -notcontains $_.Name } |
        Remove-Item -Recurse -Force

    # Repair the node_modules junction if a previous full-delete broke it.
    if ((Test-Path node_modules) -and -not (Test-Junction 'out\node_modules')) {
        Write-Host "Repairing out\node_modules junction..." -ForegroundColor Yellow
        if (Test-Path out\node_modules) { Remove-Item out\node_modules -Recurse -Force }
        cmd /c mklink /J out\node_modules node_modules | Out-Null
    }
}

Write-Host "Building (just build)..." -ForegroundColor Green
just build

if (-not $NoRun) {
    Write-Host "Launching (just run)..." -ForegroundColor Green
    just run
}
