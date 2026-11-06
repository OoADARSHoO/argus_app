import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/settings/settings_shell.dart';
import 'services/window_service.dart';

/// Root widget for Argus desktop application.
/// Sets up MaterialApp, dark theme, and displays SettingsShell.
class ArgusApp extends StatelessWidget {
  const ArgusApp({
    super.key,
    this.windowService = const WindowService(),
  });

  final WindowService windowService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Argus',
      theme: AppTheme.darkTheme,
      home: SettingsShell(windowService: windowService),
    );
  }
}
