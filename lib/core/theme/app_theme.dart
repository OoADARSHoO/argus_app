import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_typography.dart';

/// App theme definition for Argus.
/// Enforces the dark aesthetic using tokens from `lib/core/constants/`.
class AppTheme {
  AppTheme._();

  /// Builds the dark theme with an optional custom accent color.
  /// When [accentColor] is null, defaults to [AppColors.primary].
  static ThemeData darkTheme({Color? accentColor}) {
    final effectiveAccent = accentColor ?? AppColors.primary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      dividerColor: AppColors.divider,
      colorScheme: ColorScheme.dark(
        primary: effectiveAccent,
        onPrimary: AppColors.background,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.small,
      ),
    );
  }
}
