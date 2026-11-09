import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/break_overlay/break_overlay_screen.dart';
import 'screens/settings/settings_shell.dart';
import 'services/break_timer_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/tray_service.dart';
import 'services/window_service.dart';

/// Root widget for Argus desktop application.
/// Sets up MaterialApp, dark theme, and displays either the SettingsShell
/// or the BreakOverlayScreen depending on the timer phase.
///
/// Single window, two modes: the settings window or the fullscreen break
/// overlay. Rebuilds when settings change so the accent color is applied live.
class ArgusApp extends StatelessWidget {
  const ArgusApp({
    super.key,
    required this.windowService,
    required this.settingsService,
    required this.breakTimerService,
    required this.trayService,
    required this.notificationService,
  });

  final WindowService windowService;
  final SettingsService settingsService;
  final BreakTimerService breakTimerService;
  final TrayService trayService;
  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    // Create BreakOverlayScreen once outside the ListenableBuilder so its
    // State (including the animation controller) persists across timer ticks.
    // If we created it inside the builder below, every timer tick would
    // dispose the old State and create a new one, restarting the animation.
    final breakOverlayScreen = BreakOverlayScreen(
      settings: settingsService,
      timer: breakTimerService,
    );

    return ListenableBuilder(
      listenable: Listenable.merge([
        settingsService,
        breakTimerService,
      ]),
      builder: (context, _) {
        final accent = settingsService.accentColor;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Argus',
          theme: AppTheme.darkTheme(accentColor: accent),
          home: breakTimerService.phase == TimerPhase.breakTime
              ? breakOverlayScreen // Same instance — State is preserved
              : SettingsShell(
                  windowService: windowService,
                  settingsService: settingsService,
                  breakTimerService: breakTimerService,
                  trayService: trayService,
                  notificationService: notificationService,
                ),
        );
      },
    );
  }
}
