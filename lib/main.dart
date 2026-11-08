import 'package:flutter/material.dart';
import 'app.dart';
import 'services/break_timer_service.dart';
import 'services/settings_service.dart';
import 'services/window_service.dart';

/// Entry point for Argus desktop application.
/// Initializes the window, loads settings, creates and starts the break timer,
/// then runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const windowService = WindowService();
  await windowService.initializeSettingsWindow();

  // Create the settings service once and load from disk before runApp.
  final settingsService = SettingsService();
  await settingsService.load();

  // Create the break timer service once and start it.
  // Both services are passed down through constructors — no global singleton.
  final breakTimerService = BreakTimerService(
    settingsService: settingsService,
  );
  breakTimerService.start();

  runApp(ArgusApp(
    windowService: windowService,
    settingsService: settingsService,
    breakTimerService: breakTimerService,
  ));
}
