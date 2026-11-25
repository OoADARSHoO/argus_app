import 'package:flutter/material.dart';

/// Typography tokens for Argus desktop application.
/// All text styles use the bundled Inter font family.
///
/// Styles intentionally carry no color. Colors change with the theme, so the
/// theme supplies them through `ThemeData.textTheme`, or a widget applies
/// `context.palette.textPrimary` (etc.) with `copyWith`. A baked-in color here
/// would make text invisible in one of the themes.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Base typography scale (AGENTS.md Section 4)
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle bodySemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // Screen-specific typography tokens (derived from blueprints)
  static const TextStyle breakHeadline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle breakBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 26 / 17,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle countdownNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    height: 1.0,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle trayTimer = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle wordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );

  static const TextStyle titleBarWordmark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
  );
}
