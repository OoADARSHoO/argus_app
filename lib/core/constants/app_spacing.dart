import 'package:flutter/widgets.dart';

/// Spacing tokens for Argus desktop application.
/// Based on an 8px base unit with defined standard increments.
class AppSpacing {
  AppSpacing._();

  // Spacing scale
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // Semantic spacing values (AGENTS.md Section 4)
  static const double windowPadding = 24.0;
  static const double sectionGap = 32.0;
  static const double cardPadding = 20.0;
  static const double elementGap = 16.0;
  static const double iconToText = 12.0;
  static const double buttonPaddingVertical = 12.0;
  static const double buttonPaddingHorizontal = 20.0;
  static const double inputPaddingVertical = 10.0;
  static const double inputPaddingHorizontal = 14.0;
  static const double badgePaddingHorizontal = 8.0;
  static const double badgePaddingVertical = 2.0;
  static const double layoutGutter = 24.0;

  // Pre-constructed EdgeInsets instances
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: buttonPaddingVertical,
    horizontal: buttonPaddingHorizontal,
  );

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    vertical: inputPaddingVertical,
    horizontal: inputPaddingHorizontal,
  );

  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(cardPadding);

  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    vertical: badgePaddingVertical,
    horizontal: badgePaddingHorizontal,
  );

  static const EdgeInsets settingsRowPadding = EdgeInsets.symmetric(
    vertical: s12,
  );
}
