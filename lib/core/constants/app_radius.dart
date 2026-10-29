import 'package:flutter/material.dart';

/// Corner radius tokens for Argus desktop application.
/// Derived from AGENTS.md Section 4 and design blueprints.
class AppRadius {
  AppRadius._();

  // Radius scale
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double rFull = 999.0;

  // Semantic radius values
  static const double card = r12;
  static const double button = r6;
  static const double input = r6;
  static const double dropdown = r6;
  static const double badge = r8;
  static const double toggle = r12; // Pill radius for 24px height
  static const double window = r16;

  // Pre-constructed BorderRadius instances for convenience and efficiency
  static const BorderRadius borderR4 = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius borderR6 = BorderRadius.all(Radius.circular(r6));
  static const BorderRadius borderR8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius borderR12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius borderR16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius borderR24 = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius borderRFull = BorderRadius.all(Radius.circular(rFull));

  static const BorderRadius cardRadius = borderR12;
  static const BorderRadius buttonRadius = borderR6;
  static const BorderRadius inputRadius = borderR6;
  static const BorderRadius badgeRadius = borderR8;
  static const BorderRadius toggleRadius = borderR12;
}
