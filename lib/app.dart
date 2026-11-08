import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/settings/settings_shell.dart';
import 'services/break_timer_service.dart';
import 'services/settings_service.dart';
import 'services/tray_service.dart';
import 'services/window_service.dart';

/// Root widget for Argus desktop application.
/// Sets up MaterialApp, dark theme, and displays SettingsShell.
///
/// Rebuilds when settings change so the accent color is applied live.
class ArgusApp extends StatelessWidget {
  const ArgusApp({
    super.key,
    required this.windowService,
    required this.settingsService,
    required this.breakTimerService,
    required this.trayService,
  });

  final WindowService windowService;
  final SettingsService settingsService;
  final BreakTimerService breakTimerService;
  final TrayService trayService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsService,
      builder: (context, _) {
        final accent = settingsService.accentColor;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Argus',
          theme: AppTheme.darkTheme(accentColor: accent),
          home: SettingsShell(
            windowService: windowService,
            settingsService: settingsService,
            breakTimerService: breakTimerService,
            trayService: trayService,
          ),
        );
      },
    );
  }
}
