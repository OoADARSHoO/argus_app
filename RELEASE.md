# Argus — Release & Distribution Guide

Argus is an offline Windows desktop app that enforces the 20-20-20 eye-rest rule. This guide covers how to build the release binary, package it using **Velopack** into a modern self-contained installer and updater package, and distribute it to end users.

> **Note (Phase 10 Update):** Velopack (`vpk`) is now the official packaging and deployment system for Argus, replacing the legacy Inno Setup installer. The Inno Setup script is retained for historical reference only.

---

## 1. Prerequisites

1. **Flutter SDK**: Version 3.24+ (or compatible with Dart 3.8+), configured for Windows desktop development (`flutter doctor`).
2. **Visual Studio**: Visual Studio 2022 with the "Desktop development with C++" workload installed.
3. **.NET SDK**: .NET 8.0 or newer (`dotnet --version`).
4. **Velopack CLI (`vpk`)**: Install via .NET global tools:
   ```powershell
   dotnet tool install -g vpk
   ```
   *(Ensure `%USERPROFILE%\.dotnet\tools` is on your PATH).*

---

## 2. Packaging with Velopack (Official / Recommended)

A complete automated build and packaging script is provided at `scripts\package.ps1`.

### How to Build & Package:

Open a PowerShell terminal at the repository root and execute:

```powershell
.\scripts\package.ps1
```

### What the Script Does:
1. **Reads Version**: Extracts the canonical version from `argus_app\pubspec.yaml` (e.g. `1.0.0`), keeping `pubspec.yaml` as the single source of truth.
2. **Builds Release Binary**: Runs `flutter build windows --release` inside `argus_app\`.
3. **Packages with Velopack**: Runs `vpk pack` with:
   - Pack ID: `Argus`
   - Version: derived from `pubspec.yaml`
   - Main Exe: `Argus.exe`
   - Icon: `argus_app\assets\icons\app_icon.ico`
   - Title: `Argus`
   - Author: `Bitekoi Labs`
   - Pack Directory: `argus_app\build\windows\x64\runner\Release`
   - Output Directory: `Releases\` (project root)

### Packaging Output:
The generated release artifacts are saved in the `Releases\` directory at the project root:
- `ArgusSetup.exe` — Self-contained, one-click Windows installer.
- `Argus-1.0.0-full.nupkg` — Full Velopack release package (enables future delta updates).
- `releases.win.json` — Velopack release manifest (for online updates in future phases).

### What Velopack Does on the User's System:
- **Install Location**: Installs per-user to `%LOCALAPPDATA%\Argus\current\Argus.exe`. No administrator privileges required.
- **Shortcuts**: Automatically creates a Start Menu shortcut with the Argus application icon.
- **Uninstaller**: Registers cleanly in Windows Settings > Installed Apps / Control Panel Programs & Features.
- **Lifecycle Hooks**: Velopack invokes `Argus.exe` with special flags (`--veloapp-install`, `--veloapp-updated`, `--veloapp-obsolete`, `--veloapp-uninstall`). On uninstallation (`--veloapp-uninstall`), Argus automatically cleans up any Windows Startup registry entries (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Argus`).

---

## 3. How to Test the Settings Window and Updater Locally

### Test the Settings Window

1. Run `.\scripts\package.ps1` to produce `Releases\ArgusSetup.exe`.
2. Double-click `Releases\ArgusSetup.exe` to run the installer:
   - Argus will install to `%LOCALAPPDATA%\Argus\current\`.
   - The app will launch immediately upon installation.
3. Verify:
   - The settings window opens with dark theme and frameless title bar.
   - The system tray icon appears in the taskbar notification overflow area.
   - Open Windows Start Menu: "Argus" appears in the application list.
   - In Settings > General, enable **Start on Windows Startup**.
   - Check the Windows registry (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Argus`): it points to `%LOCALAPPDATA%\Argus\current\Argus.exe --autostart`.
   - Uninstall Argus from Windows Settings > Installed Apps.
   - Check the registry again: the `Argus` entry is cleanly removed.

### Test Auto-Update Locally

1. Build and package a new version:
   - Bump the version in `argus_app\pubspec.yaml` (e.g. `1.0.1`).
   - Run `.\scripts\package.ps1` to produce a new `Releases\Argus-1.0.1-full.nupkg`.
2. Start a local HTTP server in the `Releases` folder:
   ```powershell
   cd Releases
   python -m http.server 8000
   ```
3. Launch Argus with the override environment variable:
   ```powershell
   $env:ARGUS_UPDATE_URL="http://localhost:8000"
   & "$env:LOCALAPPDATA\Argus\current\Argus.exe"
   ```
4. Open the Settings window, go to **About**, and click **Check for updates**.
   - The status should change to `Update available: 1.0.1`.
   - The button should change to `Restart to update`.
   - A `Donate Now` notification should appear saying "Argus update ready. Open Settings > About to restart and install version 1.0.1."
5. Click **Restart to update**:
   - Argus should close and the updater should apply the new version.
   - When Argus restarts, the About page should show `Version 1.0.1`.
   - Your settings (break interval, theme, etc.) should be preserved.

---

## 4. Compiling the Raw Release Binary Manually

If you need only the unbundled standalone binaries without packaging into an installer:

```powershell
cd argus_app
flutter clean
flutter pub get
flutter build windows --release
```

### Release Output Location:
```
argus_app\build\windows\x64\runner\Release\
```

Contains:
- `Argus.exe` (Main application executable with embedded metadata and Argus application icon)
- `flutter_windows.dll` (Flutter desktop engine)
- Plugin DLLs (`window_manager_plugin.dll`, `tray_manager_plugin.dll`, `local_notifier_plugin.dll`, `screen_retriever_windows_plugin.dll`)
- `data/` folder (Compiled Flutter assets, fonts, icons, kernel blob)

---

## 5. Legacy: Inno Setup (Replaced by Velopack in Phase 10)

> **SUPERSEDED:** Inno Setup has been replaced by Velopack. This section is retained for reference.

The legacy Inno Setup script is located at `installer/argus.iss`.

### Building via Inno Setup (Legacy):
```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\argus.iss
```
Output was previously saved to `installer\output\Argus-Setup-1.0.0.exe`.

---

## 6. What to Distribute or Upload

For distributing Argus to users:

1. **Recommended (Velopack Setup)**:
   - Distribute `Releases\ArgusSetup.exe`.
   - Users simply run `ArgusSetup.exe` for a smooth, single-click install.
2. **Release Package for Future Cloud/GitHub Updates**:
   - Keep `Argus-<version>-full.nupkg` and `releases.win.json` together in releases storage when online updating is enabled in future phases.

---

## 7. Important End-User Notes

### Windows SmartScreen Warning
- **Why it appears**: The installer and `Argus.exe` are not signed with an Extended Validation (EV) code-signing certificate.
- **What users will see**: Windows Defender SmartScreen may display: *"Windows protected your PC — Microsoft Defender SmartScreen prevented an unrecognized app from starting."*
- **What users should do**: Click **"More info"**, then click **"Run anyway"**. Once the app gains reputation or is signed with a code-signing certificate, this warning disappears.

### Microsoft Visual C++ Redistributable
- Like all Flutter Windows desktop apps compiled with MSVC, Argus relies on the Visual C++ runtime.
- Most modern Windows 10/11 machines already have it preinstalled.
- If a user encounters an error regarding missing MSVC DLLs (e.g. `VCRUNTIME140.dll` or `MSVCP140.dll`), direct them to download the official free [Microsoft Visual C++ Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe).
