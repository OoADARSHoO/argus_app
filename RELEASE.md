# Argus — Release & Packaging Guide

This document describes how to build, package, and release Argus using Velopack.

## Overview

Argus uses **Velopack** (`vpk` CLI tool) for packaging and deployment. Releases are published to **GitHub Releases**.

## Versioning

- **Format:** `MAJOR.MINOR.PATCH+BUILD` (e.g. `0.1.15+1`)
- **Version is defined in `pubspec.yaml`** (e.g. `version: 0.1.15+1`). The packaging script reads it from there.
- **Release tags:** `v0.1.15`, `v0.1.16`, etc.
- **Release notes:** `ReleaseNotes.md` at project root.

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
