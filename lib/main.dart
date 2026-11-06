import 'package:flutter/material.dart';
import 'app.dart';
import 'services/window_service.dart';

/// Entry point for Argus desktop application.
/// Initializes the window to a fixed 960x640 size centered on screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const windowService = WindowService();
  await windowService.initializeSettingsWindow();

  runApp(const ArgusApp(windowService: windowService));
}
