import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Accent color options for Argus.
/// Defined in the Appearance settings order: Blue, Purple, Green, Orange, Pink, Teal.
class AccentColorOption {
  final String name;
  final Color color;

  const AccentColorOption({
    required this.name,
    required this.color,
  });

  static const AccentColorOption blue = AccentColorOption(
    name: 'Blue',
    color: AppColors.accentBlue,
  );

  static const AccentColorOption purple = AccentColorOption(
    name: 'Purple',
    color: AppColors.accentPurple,
  );

  static const AccentColorOption green = AccentColorOption(
    name: 'Green',
    color: AppColors.accentGreen,
  );

  static const AccentColorOption orange = AccentColorOption(
    name: 'Orange',
    color: AppColors.accentOrange,
  );

  static const AccentColorOption pink = AccentColorOption(
    name: 'Pink',
    color: AppColors.accentPink,
  );

  static const AccentColorOption teal = AccentColorOption(
    name: 'Teal',
    color: AppColors.accentTeal,
  );

  static const List<AccentColorOption> all = [
    blue,
    purple,
    green,
    orange,
    pink,
    teal,
  ];
}
