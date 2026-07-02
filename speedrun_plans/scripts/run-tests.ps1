#requires -Version 5
<#
.SYNOPSIS
    Run the MCAT engine tests (Rust concepts + Python backend + Qt score surface).
.DESCRIPTION
    The `anki` Python package is split across the source tree (pylib/, qt/) and
    generated/compiled build output (out/pylib/, out/qt/ -> buildinfo, *_pb2,
    _backend_generated, the rsbridge native module). Bare `pytest` fails with
    "No module named 'anki.buildinfo'" because those generated parts are missing
    from the path. This script builds if needed, sets PYTHONPATH across all four
    dirs, and uses the built venv's Python.
#>
$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
Set-Location $RepoRoot

# Ensure the generated module exists; build if not.
if (-not (Test-Path "$RepoRoot\out\pylib\anki\buildinfo.py")) {
    Write-Host "Build output missing; running 'just build'..." -ForegroundColor Yellow
    just build
}

$py = "$RepoRoot\out\pyenv\Scripts\python.exe"
if (-not (Test-Path $py)) { throw "Built venv not found at $py. Run 'just build' first." }
$env:PYTHONPATH = 'pylib;qt;out/pylib;out/qt'

Write-Host "== Rust concepts tests ==" -ForegroundColor Cyan
cargo test -p anki concepts::
if ($LASTEXITCODE -ne 0) { throw "Rust tests failed (exit $LASTEXITCODE)." }

Write-Host "== Python backend tests ==" -ForegroundColor Cyan
& $py -m pytest pylib/tests/test_concepts.py -v
if ($LASTEXITCODE -ne 0) { throw "Python backend tests failed (exit $LASTEXITCODE)." }

Write-Host "== Qt score-surface tests ==" -ForegroundColor Cyan
& $py -m pytest qt/aqt/mcat/tests/ -v
if ($LASTEXITCODE -ne 0) { throw "Qt tests failed (exit $LASTEXITCODE)." }

Write-Host "All tests passed." -ForegroundColor Green
