import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/demo/widget_demo_page.dart';

/// Root widget for Argus desktop application.
/// Sets up MaterialApp and dark theme.
/// In Phase 2, home points to WidgetDemoPage for shared widget verification.
class ArgusApp extends StatelessWidget {
  const ArgusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Argus',
      theme: AppTheme.darkTheme,
      home: const WidgetDemoPage(),
    );
  }
}
