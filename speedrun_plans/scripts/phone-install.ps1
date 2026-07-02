#requires -Version 5
<#
.SYNOPSIS
    Boot the emulator (if needed) and install the phone APK (FR-8 proof).
.DESCRIPTION
    Adds platform-tools/emulator to PATH, optionally boots an AVD, waits for the
    device, and installs the x86_64 debug APK built by phone-build.ps1.
.PARAMETER Sdk
    Android SDK path. Defaults to %LOCALAPPDATA%\Android\Sdk.
.PARAMETER Avd
    AVD name to boot. Defaults to anki_pixel. Use -NoBoot to skip booting.
.PARAMETER NoBoot
    Do not start the emulator; install onto an already-running device/emulator.
.PARAMETER ApkPath
    APK to install. Defaults to the x86_64 debug APK under Anki-Android.
#>
param(
    [string]$Sdk = "$env:LOCALAPPDATA\Android\Sdk",
    [string]$Avd = "anki_pixel",
    [switch]$NoBoot,
    [string]$ApkPath
)

$ErrorActionPreference = 'Stop'
$Projects = (Resolve-Path "$PSScriptRoot\..\..\..").Path
$App      = Join-Path $Projects 'Anki-Android'

$env:Path += ";$Sdk\platform-tools;$Sdk\emulator"

if (-not $ApkPath) {
    $ApkPath = Join-Path $App 'AnkiDroid\build\outputs\apk\play\debug\AnkiDroid-play-x86_64-debug.apk'
}
if (-not (Test-Path $ApkPath)) { throw "APK not found: $ApkPath  (run phone-build.ps1 first)" }

if (-not $NoBoot) {
    Write-Host "Booting emulator '$Avd'..." -ForegroundColor Green
    Start-Process emulator.exe -ArgumentList "-avd $Avd"
    Write-Host "Waiting for device..." -ForegroundColor Yellow
    adb wait-for-device
    # wait until boot completes
    do {
        Start-Sleep -Seconds 3
        $booted = (adb shell getprop sys.boot_completed 2>$null).Trim()
    } while ($booted -ne '1')
}

Write-Host "Installing APK: $ApkPath" -ForegroundColor Green
adb install -r "$ApkPath"
Write-Host "Done. Open the app, load the MCAT deck, and run a review session." -ForegroundColor Green
