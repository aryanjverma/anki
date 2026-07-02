#requires -Version 5
<#
.SYNOPSIS
    Build the phone app (shared Rust engine + APKs) from source.
.DESCRIPTION
    Builds the AnkiDroid backend (.aar/.so, which bundles the shared Rust engine
    with the concepts change) then assembles the debug APKs. Assumes the sibling
    repos Anki-Android and Anki-Android-Backend live next to this fork under
    ...\projects\, the Android SDK is installed, and Rust android targets exist.
.PARAMETER Sdk
    Android SDK path. Defaults to %LOCALAPPDATA%\Android\Sdk.
.PARAMETER NdkVersion
    NDK version under <Sdk>\ndk. Defaults to 29.0.14206865.
#>
param(
    [string]$Sdk = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$NdkVersion = "29.0.14206865"
)

$ErrorActionPreference = 'Stop'
$Projects = (Resolve-Path "$PSScriptRoot\..\..\..").Path   # ...\projects
$Backend  = Join-Path $Projects 'Anki-Android-Backend'
$App      = Join-Path $Projects 'Anki-Android'

foreach ($p in @($Backend, $App)) {
    if (-not (Test-Path $p)) { throw "Expected repo not found: $p" }
}

$env:ANDROID_HOME     = $Sdk
$env:ANDROID_NDK_HOME = Join-Path $Sdk "ndk\$NdkVersion"
if (-not (Test-Path $env:ANDROID_NDK_HOME)) { throw "NDK not found: $env:ANDROID_NDK_HOME" }
Write-Host "ANDROID_HOME     = $env:ANDROID_HOME" -ForegroundColor Cyan
Write-Host "ANDROID_NDK_HOME = $env:ANDROID_NDK_HOME" -ForegroundColor Cyan

Write-Host "[1/2] Building shared Rust engine (backend .aar/.so)..." -ForegroundColor Green
Set-Location $Backend
git submodule update --init --recursive
& "$Backend\build.bat"
if ($LASTEXITCODE -ne 0) { throw "Backend build failed (exit $LASTEXITCODE)." }

Write-Host "[2/2] Assembling debug APKs..." -ForegroundColor Green
Set-Location $App
& "$App\gradlew.bat" assemblePlayDebug
if ($LASTEXITCODE -ne 0) { throw "APK assembly failed (exit $LASTEXITCODE)." }

$apks = Get-ChildItem "$App\AnkiDroid\build\outputs\apk\play\debug\*.apk" -ErrorAction SilentlyContinue
Write-Host "APKs built:" -ForegroundColor Green
$apks | ForEach-Object { Write-Host "  $($_.FullName)" }
