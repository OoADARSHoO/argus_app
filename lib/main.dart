import 'package:flutter/material.dart';
import 'app.dart';
import 'services/settings_service.dart';
import 'services/window_service.dart';

/// Entry point for Argus desktop application.
/// Initializes the window, loads settings from disk, then runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const windowService = WindowService();
  await windowService.initializeSettingsWindow();

  // Create the settings service once and load from disk before runApp.
  // The service is passed down through constructors — no global singleton.
  final settingsService = SettingsService();
  await settingsService.load();

  runApp(ArgusApp(
    windowService: windowService,
    settingsService: settingsService,
  ));
}
