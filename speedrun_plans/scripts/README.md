# Build & install scripts (Wednesday demo)

PowerShell scripts for the clean-build and install proofs. Run from anywhere; each
resolves the repo (and sibling mobile repos) itself.

| Script                       | What it does                                                        |
| ---------------------------- | ------------------------------------------------------------------ |
| `desktop-clean-build.ps1`    | Clean build outputs (keeps toolchain), `just build`, then `just run`. `-Full` = wipe everything incl. root `node_modules`; `-NoRun` to skip run |
| `desktop-build-installer.ps1`| Build the MSI (`tools\build-installer.bat`); prints the MSI path    |
| `desktop-install.ps1`        | Install the newest MSI (`-Silent` for unattended; `-MsiPath` opt.)  |
| `phone-build.ps1`            | Build shared Rust engine + assemble debug APKs                      |
| `phone-install.ps1`          | Boot the `anki_pixel` AVD and install the x86_64 APK (`-NoBoot` opt.)|

If scripts are blocked by execution policy, run once per session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Clean-build note (Windows)

`out\node_modules` is a *junction* to the repo-root `node_modules`. Do **not**
`rm -r out` by hand — it breaks the junction and the build then fails with missing
`tsx.cmd` / `sass.cmd` / `jquery` / `mathjax`. Use `desktop-clean-build.ps1`, which
keeps the toolchain (or repairs the junction) automatically. For the *truest*
clean-build recording, build from a fresh `git clone` in a new folder.

