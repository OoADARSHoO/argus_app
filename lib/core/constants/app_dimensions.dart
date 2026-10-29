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

  // Toggle switch
  static const double toggleWidth = 44.0;
  static const double toggleHeight = 24.0;
  static const Size toggleSize = Size(toggleWidth, toggleHeight);

  // Radius (cross-referenced for consistency)
  static const double cardRadius = 12.0;

  // Icons
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;

  // Progress rings
  static const double progressRingComponent = 120.0;
  static const double progressRingBreakScreen = 160.0;

  // Badge
  static const double badgeHeight = 18.0;

  // Break screen (reference resolution)
  static const double breakScreenRefWidth = 1920.0;
  static const double breakScreenRefHeight = 1080.0;
}
