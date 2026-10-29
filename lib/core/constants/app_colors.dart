import 'package:flutter/material.dart';

/// Design color tokens for Argus desktop application.
/// All hex values match AGENTS.md (Section 4) and design blueprints.
class AppColors {
  AppColors._();

  // Primary brand / accent colors
  static const Color primary = Color(0xFF5B8CFF);
  static const Color primaryLight = Color(0xFF7BA6FF);
  static const Color primaryDark = Color(0xFF2E5DFF);

  // Background and surface colors
  static const Color background = Color(0xFF0E0E10);
  static const Color surface = Color(0xFF16161B);
  static const Color surfaceElevated = Color(0xFF1E1E24);

  // Borders and dividers
  static const Color border = Color(0xFF2A2A33);
  static const Color divider = Color(0xFF24242C);

  // Typography / Text hierarchy
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFF52525B);

  // Status and feedback colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Accent color swatches (Appearance settings: blue, purple, green, orange, pink, teal)
  static const Color accentBlue = primary; // #5B8CFF
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFF5A623);
  static const Color accentPink = Color(0xFFF0507C);
  static const Color accentTeal = Color(0xFF22C3D6);

  // Active / Selected state background opacity (12% to 15%)
  static const double activeOpacity = 0.12;
}
