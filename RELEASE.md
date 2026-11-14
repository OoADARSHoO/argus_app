# Argus — Release & Packaging Guide

This document describes how to build, package, and release Argus using Velopack.

## Overview

Argus uses **Velopack** (`vpk` CLI tool) for packaging and deployment. Releases are published to **GitHub Releases**.

## Versioning

- **Format:** `MAJOR.MINOR.PATCH+BUILD` (e.g. `0.2.0+1`)
- **Important:** Velopack requires a standard 3-part SemVer number before the `+` (e.g. `0.2.0`, not `0.2`).
- **Version is defined in `pubspec.yaml`** (e.g. `version: 0.2.0+1`). Both packaging and publishing scripts read it from there as the single source of truth.
- **Release tags:** Automatically formatted as `v0.2.0`, `v0.2.1`, etc.

## How to Publish a Release to GitHub (One-Command Flow)

When you make changes and want to publish a new release:

### Step 1: Bump version in `pubspec.yaml`
Open `pubspec.yaml` and update the version line (use SemVer `X.Y.Z+build`):
```yaml
version: 0.2.0+1
```

### Step 2: Commit and push your changes to GitHub
```powershell
git add .
git commit -m "V0.2.0 (feature description)"
git push origin main
```

### Step 3: Run the publish script
```powershell
.\scripts\publish.ps1
```
*(Optional: you can also pass notes: `.\scripts\publish.ps1 -Notes "Fixed issue with countdown"`)*

The script automatically:
1. Reads `version` from `pubspec.yaml`.
2. Compiles Flutter Windows release binary and packages installer + update assets with `vpk pack`.
3. Creates git tag `v0.2.0` and pushes it to GitHub.
4. Uses your stored GitHub credentials to upload the release directly to [GitHub Releases](https://github.com/OoADARSHoO/argus_app/releases).
5. Existing installations of Argus will automatically detect the new release via their built-in update check!

---

## Local testing

To test the auto-updater locally without a GitHub release:

1. Build and package version **0.1.15**:
   ```
   .\scripts\package.ps1
   ```
2. Install it via `Releases\Argus-win-Setup.exe`.
3. Run Argus from the install location (`%LOCALAPPDATA%\Argus\current\Argus.exe`).
4. Bump version in `pubspec.yaml` to **0.1.16** and package again:
   ```
   .\scripts\package.ps1
   ```
5. Serve the new `Releases` folder over HTTP at `http://localhost:8000`:
   ```
   python -m http.server 8000
   ```
6. Set the environment variable before launching the installed Argus:
   ```
   $env:ARGUS_UPDATE_URL = "http://localhost:8000"
   ```
7. Launch the installed Argus. It should detect and offer the update within 30 seconds.

## Velopack Update.exe location

After installing via Velopack, `Update.exe` is located at:
`%LOCALAPPDATA%\Argus\Update.exe` (parent of the `current\` folder).

## Velopack Update.exe CLI

The `Update.exe` provided by Velopack supports:
```
Update.exe apply --package <FILE> --waitPid <PID>
```
This command applies the package and restarts the application automatically after the update.

## Troubleshooting

- **"Update.exe not found"**: The app is not installed via Velopack (running from `flutter run`). The updater is disabled.
- **"Update ready" notification**: Open Settings > About and click "Restart to update".
