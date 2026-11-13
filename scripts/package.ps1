# =============================================================================
# scripts\package.ps1  –  Build & package Argus with Velopack
#
# Run from the repo root (argus_app\):
#
#   .\scripts\package.ps1
#
# Prerequisites:
#   • Flutter SDK on PATH
#   • .NET SDK 8+ on PATH  (`dotnet --version`)
#   • vpk global tool      (`dotnet tool install -g vpk`)
#   • Visual Studio 2022 "Desktop development with C++" workload
#
# Output:
#   Releases\             ← created at repo root (argus_app\)
#     Argus-win-Setup.exe   ← one-click installer for first-time users
#     Argus-1.x.y-full.nupkg   ← full package (used by delta updater later)
#     releases.win.json   ← release manifest (required by online updater, ignored for now)
# =============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 0. Resolve paths relative to this script's location.
#    $PSScriptRoot = argus_app\scripts\
#    $PSScriptRoot\..   = argus_app\   (repo root)
# ---------------------------------------------------------------------------
$repoRoot = Split-Path -Parent $PSScriptRoot   # argus_app\
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$releaseExeDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
$iconPath    = Join-Path $repoRoot "assets\icons\app_icon.ico"
$releasesDir = Join-Path $repoRoot "Releases"

# ---------------------------------------------------------------------------
# 1. Read the version from pubspec.yaml  (single source of truth).
#    pubspec line format:  version: 1.2.3+4
#    We take only the SemVer part before the '+'.
# ---------------------------------------------------------------------------
Write-Host "`n[1/4] Reading version from pubspec.yaml..." -ForegroundColor Cyan

if (-not (Test-Path $pubspecPath)) {
    Write-Error "pubspec.yaml not found at: $pubspecPath"
    exit 1
}

$pubspecContent = Get-Content $pubspecPath -Raw
if ($pubspecContent -match '(?m)^version:\s+(\d+\.\d+\.\d+)') {
    $version = $Matches[1]
} else {
    Write-Error "Could not parse version from pubspec.yaml. Expected a line like: version: 1.0.0+1"
    exit 1
}

Write-Host "  Version: $version" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. Build the Flutter Windows release binary.
# ---------------------------------------------------------------------------
Write-Host "`n[2/4] Building Flutter Windows release..." -ForegroundColor Cyan

Push-Location $repoRoot
try {
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "flutter build windows --release failed (exit code $LASTEXITCODE)"
        exit 1
    }
} finally {
    Pop-Location
}

# Verify the main executable was produced.
$mainExePath = Join-Path $releaseExeDir "Argus.exe"
if (-not (Test-Path $mainExePath)) {
    Write-Error "Build succeeded but Argus.exe not found at: $mainExePath"
    exit 1
}
Write-Host "  Build output: $releaseExeDir" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3. Resolve vpk executable.
#    After `dotnet tool install -g vpk`, the tool lands in %USERPROFILE%\.dotnet\tools.
#    That directory may not be on PATH yet in the current shell session, so we
#    also try the known default location before giving up.
# ---------------------------------------------------------------------------
Write-Host "`n[3/4] Locating vpk..." -ForegroundColor Cyan

$vpkCmd = $null

# Try PATH first (works after a shell restart or if the user added it manually).
$vpkOnPath = Get-Command vpk -ErrorAction SilentlyContinue
if ($vpkOnPath) {
    $vpkCmd = 'vpk'
    Write-Host "  vpk found on PATH: $($vpkOnPath.Source)" -ForegroundColor Green
} else {
    # Fall back to the standard dotnet global-tools location.
    $dotnetToolsDir = Join-Path $env:USERPROFILE '.dotnet\tools'
    $vpkExe = Join-Path $dotnetToolsDir 'vpk.exe'
    if (Test-Path $vpkExe) {
        $vpkCmd = $vpkExe
        Write-Host "  vpk found at: $vpkExe" -ForegroundColor Green
        Write-Host "  TIP: Add '$dotnetToolsDir' to your PATH so 'vpk' works in any terminal:" -ForegroundColor Yellow
        Write-Host "       setx PATH `"%PATH%;$dotnetToolsDir`"" -ForegroundColor Yellow
    } else {
        Write-Error @"
vpk is not installed.
Install it with:
  dotnet tool install -g vpk
Then either restart your terminal or run this script again.
"@
        exit 1
    }
}

# ---------------------------------------------------------------------------
# 4. Package with Velopack.
# ---------------------------------------------------------------------------
Write-Host "`n[4/4] Packaging with Velopack (vpk pack)..." -ForegroundColor Cyan

# Ensure the output directory exists.
if (-not (Test-Path $releasesDir)) {
    New-Item -ItemType Directory -Path $releasesDir | Out-Null
} else {
    # If packaging the same version again locally, remove previous artifacts
    # so Velopack does not complain about an existing release with >= version.
    Get-ChildItem -Path $releasesDir -File | Where-Object {
        $_.Name -match [regex]::Escape($version) -or $_.Name -match '^releases\.' -or $_.Name -eq 'RELEASES' -or $_.Name -match '^assets\.'
    } | Remove-Item -Force
}

# vpk pack arguments:
#   --packId       Unique app ID (no spaces). Used as the registry/uninstall key.
#   --packVersion  SemVer version string read from pubspec.yaml above.
#   --packDir      Folder containing Argus.exe and its runtime DLLs / data\.
#   --mainExe      Filename (not path) of the main executable.
#   --icon         Path to the .ico file embedded into the Setup exe.
#   --packTitle    Human-readable product name shown in the installer UI.
#   --packAuthors  Publisher name shown in Windows Apps & Features.
#   --runtime      Target RID: win-x64 matches Flutter's x64 Release output.
#   --framework    VC++ runtime to bundle as a prerequisite (vc143-x64 covers
#                  the MSVC runtime most Flutter/Windows apps need).
#   --outputDir    Where Releases\ artifacts are written.
& $vpkCmd pack `
    --packId      "Argus" `
    --packVersion $version `
    --packDir     $releaseExeDir `
    --mainExe     "Argus.exe" `
    --icon        $iconPath `
    --packTitle   "Argus" `
    --packAuthors "Bitekoi Labs" `
    --runtime     "win-x64" `
    --framework   "vcredist143-x64" `
    --outputDir   $releasesDir

if ($LASTEXITCODE -ne 0) {
    Write-Error "vpk pack failed (exit code $LASTEXITCODE)"
    exit 1
}

Write-Host "`n✅ Packaging complete!" -ForegroundColor Green
Write-Host "   Output folder : $releasesDir" -ForegroundColor Green
Write-Host "   Run the Setup exe (e.g. Argus-win-Setup.exe) to install and test." -ForegroundColor Yellow
Write-Host "   The installed app will live at: %LOCALAPPDATA%\Argus\current\Argus.exe" -ForegroundColor Yellow