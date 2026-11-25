import 'package:flutter/material.dart';

/// Theme-independent color tokens for Argus.
///
/// Colors that change between the dark and light themes (background, surface,
/// borders, text hierarchy, toggle track) live in `AppPalette` instead. This
/// file keeps only colors that are the same in every theme: brand accents,
/// status colors, black/white/transparent, and the break-screen backgrounds.
/// All hex values match AGENTS.md (Section 4) and design blueprints.
class AppColors {
  AppColors._();

  // Primary brand / accent colors
  static const Color primary = Color(0xFF5B8CFF);
  static const Color primaryLight = Color(0xFF7BA6FF);
  static const Color primaryDark = Color(0xFF2E5DFF);

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

  static const List<Color> accentColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentOrange,
    accentPink,
    accentTeal,
  ];

  // Utility colors
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Break screen background colors (Break settings: Black Screen / Dark Gray / Deep Blue)
  static const Color breakBackgroundBlackScreen = Color(0xFF0E0E10);
  static const Color breakBackgroundDarkGray = Color(0xFF1A1A1E);
  static const Color breakBackgroundDeepBlue = Color(0xFF16213E);

  /// Returns the break background color for the given background id.
  static Color breakBackgroundForId(String id) {
    switch (id) {
      case 'dark_gray':
        return breakBackgroundDarkGray;
      case 'deep_blue':
        return breakBackgroundDeepBlue;
      case 'black_screen':
      default:
        return breakBackgroundBlackScreen;
    }
  }

  // Active / Selected state background opacity (12% to 15%)
  static const double activeOpacity = 0.12;
}
