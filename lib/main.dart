import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/constants/app_dimensions.dart';

/// Entry point for Argus desktop application.
/// Initializes the window to a fixed 960x640 size centered on screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize desktop window manager
  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    size: AppDimensions.windowSize,
    minimumSize: AppDimensions.windowSize,
    maximumSize: AppDimensions.windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: 'Argus',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ArgusApp());
}