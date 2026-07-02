# Build & install scripts (Wednesday demo)

PowerShell scripts for the clean-build and install proofs. Run from anywhere; each
resolves the repo (and sibling mobile repos) itself.

| Script                       | What it does                                                        |
| ---------------------------- | ------------------------------------------------------------------ |
| `desktop-clean-build.ps1`    | Delete `out/`, `just build`, then `just run` (`-NoRun` to skip run) |
| `desktop-build-installer.ps1`| Build the MSI (`tools\build-installer.bat`); prints the MSI path    |
| `desktop-install.ps1`        | Install the newest MSI (`-Silent` for unattended; `-MsiPath` opt.)  |
| `phone-build.ps1`            | Build shared Rust engine + assemble debug APKs                      |
| `phone-install.ps1`          | Boot the `anki_pixel` AVD and install the x86_64 APK (`-NoBoot` opt.)|

If scripts are blocked by execution policy, run once per session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
