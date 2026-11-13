import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

/// Service managing auto-launch at Windows startup using [launch_at_startup].
///
/// Plain class, created once in [main.dart].
///
/// WARNING FOR DEVELOPMENT / PACKAGING:
/// When running with `flutter run`, `Platform.resolvedExecutable` resolves to
/// the debug executable (e.g. `build\windows\x64\runner\Debug\Argus.exe`).
/// In production when installed via Velopack, it resolves to the stable installed
/// path `%LOCALAPPDATA%\Argus\current\Argus.exe`, ensuring the Windows startup
/// registry key points to the current active release.
class StartupService {
  static const String _appName = 'Argus';
  static const String autostartArg = '--autostart';

  bool _isInitialized = false;

  /// Sets up launch_at_startup configuration.
  ///
  /// Wrapped in try/catch so unexpected environment errors never crash the app.
  void setup() {
    try {
      launchAtStartup.setup(
        appName: _appName,
        appPath: Platform.resolvedExecutable,
        args: const [autostartArg],
      );
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('StartupService.setup error: $e\n$stackTrace');
    }
  }

  /// Synchronizes the real Windows startup registration with [enableStartup].
  ///
  /// Wrapped in try/catch so registry or permission failures never crash the app.
  Future<void> syncWithSetting(bool enableStartup) async {
    if (!_isInitialized) {
      setup();
    }

    try {
      final isCurrentlyEnabled = await launchAtStartup.isEnabled();
      if (enableStartup && !isCurrentlyEnabled) {
        await launchAtStartup.enable();
        debugPrint('StartupService: Registered $_appName to launch at Windows startup with $autostartArg');
      } else if (!enableStartup && isCurrentlyEnabled) {
        await launchAtStartup.disable();
        debugPrint('StartupService: Unregistered $_appName from Windows startup');
      }
    } catch (e, stackTrace) {
      debugPrint('StartupService.syncWithSetting error: $e\n$stackTrace');
    }
  }

  /// Checks if launch at startup is currently enabled in Windows.
  Future<bool> isEnabled() async {
    if (!_isInitialized) {
      setup();
    }
    try {
      return await launchAtStartup.isEnabled();
    } catch (e, stackTrace) {
      debugPrint('StartupService.isEnabled error: $e\n$stackTrace');
      return false;
    }
  }
}
