# =============================================================================
# scripts\publish.ps1 – Build, Package, Tag & Publish Argus to GitHub Releases
#
# Run from the repo root (argus_app\):
#
#   .\scripts\publish.ps1
#
# Or with optional release notes:
#   .\scripts\publish.ps1 -Notes "Added new feature X and fixed bug Y"
#
# What it does:
#   1. Reads version from pubspec.yaml (e.g. 0.2.0).
#   2. Builds & packages with Velopack (calls .\scripts\package.ps1).
#   3. Tags git with v<version> and pushes tag to GitHub.
#   4. Retrieves GitHub token automatically from Windows Credential Manager.
#   5. Uploads all installer and update assets to GitHub Releases via Velopack.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$Notes = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot   # argus_app\
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$releasesDir = Join-Path $repoRoot "Releases"

# ---------------------------------------------------------------------------
# 1. Read version from pubspec.yaml
# ---------------------------------------------------------------------------
Write-Host "`n[1/5] Checking version in pubspec.yaml..." -ForegroundColor Cyan

if (-not (Test-Path $pubspecPath)) {
    Write-Error "pubspec.yaml not found at: $pubspecPath"
    exit 1
}

$pubspecContent = Get-Content $pubspecPath -Raw
if ($pubspecContent -match '(?m)^version:\s+(\d+\.\d+\.\d+)') {
    $version = $Matches[1]
} else {
    Write-Error @"
Could not parse a valid 3-part SemVer version from pubspec.yaml.
Velopack requires SemVer format: MAJOR.MINOR.PATCH (e.g. '0.2.0+1', not '0.2').
Please update pubspec.yaml to e.g. 'version: 0.2.0+1'.
"@
    exit 1
}

$tag = "v$version"
Write-Host "  Target version: $version (Tag: $tag)" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. Get GitHub Token
# ---------------------------------------------------------------------------
Write-Host "`n[2/5] Resolving GitHub credentials..." -ForegroundColor Cyan

$token = $env:GH_TOKEN
if (-not $token) {
    # Attempt to retrieve token from Git Credential Manager (stored during git push)
    $inputStr = "protocol=https`nhost=github.com`n`n"
    $output = $inputStr | git credential fill 2>$null
    foreach ($line in $output) {
        if ($line -match '^password=(.+)$') {
            $token = $Matches[1]
            break
        }
    }
}

if (-not $token) {
    Write-Error @"
Could not find a GitHub token.
Please set your token in the environment:
  `$env:GH_TOKEN = 'your_personal_access_token'
Or run 'gh auth login' or 'git push' to store credentials.
"@
    exit 1
}
Write-Host "  GitHub credentials found." -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3. Build & Package with Velopack
# ---------------------------------------------------------------------------
Write-Host "`n[3/5] Packaging release with Velopack..." -ForegroundColor Cyan

$packageScript = Join-Path $PSScriptRoot "package.ps1"
if (-not (Test-Path $packageScript)) {
    Write-Error "package.ps1 not found at: $packageScript"
    exit 1
}

Push-Location $repoRoot
try {
    & powershell -ExecutionPolicy Bypass -File $packageScript
    if ($LASTEXITCODE -ne 0) {
        Write-Error "package.ps1 failed with code $LASTEXITCODE"
        exit 1
    }
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
# 4. Create and Push Git Tag
# ---------------------------------------------------------------------------
Write-Host "`n[4/5] Updating Git tag..." -ForegroundColor Cyan

Push-Location $repoRoot
try {
    # Check if tag already exists locally
    $localTag = & git tag -l $tag
    if (-not $localTag) {
        & git tag -a $tag -m "Release $tag"
        Write-Host "  Created local tag $tag" -ForegroundColor Green
    } else {
        Write-Host "  Local tag $tag already exists" -ForegroundColor Yellow
    }

    # Push tag to remote
    & git push origin $tag
    Write-Host "  Pushed tag $tag to GitHub" -ForegroundColor Green
} finally {
    Pop-Location
}

# ---------------------------------------------------------------------------
# 5. Upload to GitHub Releases
# ---------------------------------------------------------------------------
Write-Host "`n[5/5] Uploading release assets to GitHub Releases..." -ForegroundColor Cyan

# Locate vpk
$vpkCmd = $null
$vpkOnPath = Get-Command vpk -ErrorAction SilentlyContinue
if ($vpkOnPath) {
    $vpkCmd = 'vpk'
} else {
    $vpkExe = Join-Path $env:USERPROFILE '.dotnet\tools\vpk.exe'
    if (Test-Path $vpkExe) {
        $vpkCmd = $vpkExe
    } else {
        Write-Error "vpk executable not found. Install with: dotnet tool install -g vpk"
        exit 1
    }
}

$repoUrl = "https://github.com/OoADARSHoO/argus_app"

& $vpkCmd upload github `
    --repoUrl     $repoUrl `
    --token       $token `
    --outputDir   $releasesDir `
    --tag         $tag `
    --releaseName "Argus $tag" `
    --publish

if ($LASTEXITCODE -ne 0) {
    Write-Error "vpk upload github failed (exit code $LASTEXITCODE)"
    exit 1
}

# Optional: if custom notes provided and gh CLI is available, update release body
if ($Notes) {
    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghCmd) {
        try {
            $env:GH_TOKEN = $token
            & gh release edit $tag --repo OoADARSHoO/argus_app --notes "$Notes" 2>$null
        } catch {
            # Non-fatal if gh edit fails
        }
    }
}

Write-Host "`n🎉 Successfully published $tag to GitHub!" -ForegroundColor Green
Write-Host "   Release URL: $repoUrl/releases/tag/$tag" -ForegroundColor Green
Write-Host "   Users can download Argus-win-Setup.exe and existing installs will auto-update!" -ForegroundColor Yellow

