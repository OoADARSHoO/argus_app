import 'package:flutter/material.dart';
import 'app.dart';
import 'services/break_timer_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/tray_service.dart';
import 'services/window_service.dart';

/// Entry point for Argus desktop application.
/// Initializes the window, loads settings, creates and starts the break timer,
/// creates the notification and tray services, then runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = SettingsService();
  await settingsService.load();

  // WindowService needs the onCloseRequested callback to flush pending
  // settings when the user tries to close the window (X or Alt+F4).
  final windowService = WindowService(
    onCloseRequested: () => settingsService.flush(),
  );
  await windowService.initializeSettingsWindow();

  // Create the break timer service once and start it.
  final breakTimerService = BreakTimerService(
    settingsService: settingsService,
  );
  breakTimerService.start();

  // Create the notification service once and set it up at startup.
  final notificationService = NotificationService();
  await notificationService.setup();

  // Listen to timer phase transitions and switch window overlay mode.
  // When the timer enters breakTime, the window goes fullscreen always-on-top
  // and shows the break overlay. When it leaves breakTime, the window is
  // restored to its pre-break state.
  TimerPhase lastTimerPhase = TimerPhase.working;

  // Track preBreakWarning edge (false -> true) so the notification fires
  // exactly once per cycle, not on every tick.
  bool lastPreBreakWarning = false;
  breakTimerService.addListener(() {
    final currentPhase = breakTimerService.phase;
    if (lastTimerPhase != currentPhase) {
      lastTimerPhase = currentPhase;
      if (currentPhase == TimerPhase.breakTime) {
        windowService.enterOverlayMode();
      } else {
        windowService.exitOverlayMode();
      }
    }

    // Pre-break warning: fire exactly once when it turns on (edge only).
    // The service already gates on Show Notifications; we do not duplicate
    // that check here.
    if (breakTimerService.preBreakWarning && !lastPreBreakWarning) {
      notificationService.showBreakWarning(
        breakTimerService.secondsUntilBreak,
      );
    }
    lastPreBreakWarning = breakTimerService.preBreakWarning;
  });

  // Create the tray service once and initialize it.
  final trayService = TrayService(
    settingsService: settingsService,
    breakTimerService: breakTimerService,
    windowService: windowService,
  );
  await trayService.init();

  runApp(ArgusApp(
    windowService: windowService,
    settingsService: settingsService,
    breakTimerService: breakTimerService,
    trayService: trayService,
    notificationService: notificationService,
  ));
}
