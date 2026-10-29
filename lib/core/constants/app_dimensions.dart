import 'package:flutter/material.dart';

/// Dimension tokens for Argus desktop application.
/// Derived from AGENTS.md Section 4.
class AppDimensions {
  AppDimensions._();

  // Settings window
  static const double windowWidth = 960.0;
  static const double windowHeight = 640.0;
  static const Size windowSize = Size(windowWidth, windowHeight);

  // Title bar
  static const double titleBarHeight = 32.0;

  // Sidebar
  static const double sidebarWidth = 180.0;
  static const double sidebarItemWidth = 160.0;
  static const double sidebarItemHeight = 40.0;
  static const Size sidebarItemSize = Size(sidebarItemWidth, sidebarItemHeight);

  // Buttons & Controls
  static const double buttonHeight = 40.0;
  static const double iconButtonSize = 40.0;
  static const double inputHeight = 36.0;
  static const double dropdownHeight = 36.0;
  static const double dropdownWidth = 140.0;
  static const double multilineInputMinHeight = 72.0;

  // Toggle switch
  static const double toggleWidth = 44.0;
  static const double toggleHeight = 24.0;
  static const double toggleKnobSize = 20.0;
  static const double togglePadding = 2.0;
  static const Size toggleSize = Size(toggleWidth, toggleHeight);

  // Settings Row
  static const double settingsRowMinHeight = 64.0;

  // Accent Swatch
  static const double accentSwatchSize = 28.0;
  static const double accentSwatchRingGap = 2.0;
  static const double accentSwatchRingWidth = 2.0;
  static const double accentSwatchTotalSize = 36.0;
  static const double accentSwatchCheckSize = 14.0;

  // Theme Option Card
  static const double themeCardWidth = 104.0;
  static const double themeCardHeight = 84.0;
  static const double themeBadgeSize = 16.0;

  // Borders
  static const double borderWidth = 1.0;

  // Radius (cross-referenced for consistency)
  static const double cardRadius = 12.0;

  // Icons
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;

  // Progress rings
  static const double progressRingComponent = 120.0;
  static const double progressRingBreakScreen = 160.0;
  static const double progressRingSupport = 200.0;
  static const double progressRingStrokeWidthDefault = 10.0;
  static const double progressRingStrokeWidthBreak = 12.0;
  static const double progressRingStrokeWidthSupport = 16.0;

  // Badge
  static const double badgeHeight = 18.0;

  // Break screen (reference resolution)
  static const double breakScreenRefWidth = 1920.0;
  static const double breakScreenRefHeight = 1080.0;
}
