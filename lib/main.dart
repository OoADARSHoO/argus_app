import 'package:flutter/material.dart';
import 'app.dart';
import 'services/break_timer_service.dart';
import 'services/settings_service.dart';
import 'services/tray_service.dart';
import 'services/window_service.dart';

/// Entry point for Argus desktop application.
/// Initializes the window, loads settings, creates and starts the break timer,
/// creates the tray service, then runs the app.
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
  ));
}
