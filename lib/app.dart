import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/theme/app_theme.dart';

/// Root widget for Argus desktop application.
/// Sets up the MaterialApp, dark theme, and initial blank dark window.
class ArgusApp extends StatelessWidget {
  const ArgusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Argus',
      theme: AppTheme.darkTheme,
      home: const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'ARGUS',
            style: AppTypography.wordmark,
          ),
        ),
      ),
    );
  }
}
