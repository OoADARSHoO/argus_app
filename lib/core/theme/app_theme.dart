import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_typography.dart';
import 'app_palette.dart';

/// App theme definition for Argus.
///
/// Both themes are built from the same tokens; only the [AppPalette] and the
/// [Brightness] differ. The dark theme is intentionally identical to the
/// pre-Phase 13E look.
class AppTheme {
  AppTheme._();

  /// Builds the dark theme with an optional custom accent color.
  /// When [accentColor] is null, defaults to [AppColors.primary].
  static ThemeData darkTheme({Color? accentColor}) {
    return _buildTheme(
      palette: AppPalette.dark,
      brightness: Brightness.dark,
      accentColor: accentColor,
    );
  }

  /// Builds the light theme with an optional custom accent color.
  static ThemeData lightTheme({Color? accentColor}) {
    return _buildTheme(
      palette: AppPalette.light,
      brightness: Brightness.light,
      accentColor: accentColor,
    );
  }

  /// Maps the saved `themeId` to a [ThemeMode].
  ///
  /// Anything unknown falls back to dark, which is the app's default and the
  /// safest look if a settings file is corrupted.
  static ThemeMode themeModeForId(String themeId) {
    switch (themeId) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  /// The native window background to use before Flutter paints its first
  /// frame.
  ///
  /// The settings window is shown before `runApp`, so it must already match
  /// the saved theme. Otherwise a light-theme user sees a dark flash (or the
  /// reverse). For `system`, read the platform brightness that the Windows
  /// engine loaded from the "app mode" setting at startup.
  static Color startupBackgroundFor(String themeId) {
    final mode = themeModeForId(themeId);
    final brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    return brightness == Brightness.light
        ? AppPalette.light.background
        : AppPalette.dark.background;
  }

  static ThemeData _buildTheme({
    required AppPalette palette,
    required Brightness brightness,
    Color? accentColor,
  }) {
    final effectiveAccent = accentColor ?? AppColors.primary;
    final isDark = brightness == Brightness.dark;

    // Keep the dark ColorScheme exactly as it was before Phase 13E. The light
    // one mirrors it with light surfaces and dark text.
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: effectiveAccent,
            onPrimary: palette.background,
            secondary: AppColors.primaryLight,
            onSecondary: palette.textPrimary,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: AppColors.error,
            onError: palette.textPrimary,
          )
        : ColorScheme.light(
            primary: effectiveAccent,
            onPrimary: palette.background,
            secondary: AppColors.primaryLight,
            onSecondary: palette.textPrimary,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: AppColors.error,
            onError: palette.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.surface,
      dividerColor: palette.divider,
      colorScheme: colorScheme,
      // Widgets read the active palette through `context.palette`.
      extensions: <ThemeExtension<dynamic>>[palette],
      iconTheme: IconThemeData(color: palette.textPrimary),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: palette.border, width: 1.0),
        ),
      ),
      // These defaults keep any text that forgets an explicit color readable.
      textTheme: TextTheme(
        headlineLarge:
            AppTypography.heading1.copyWith(color: palette.textPrimary),
        headlineMedium:
            AppTypography.heading2.copyWith(color: palette.textPrimary),
        bodyLarge:
            AppTypography.bodyLarge.copyWith(color: palette.textPrimary),
        bodyMedium: AppTypography.body.copyWith(color: palette.textPrimary),
        bodySmall: AppTypography.caption.copyWith(color: palette.textSecondary),
        labelSmall: AppTypography.small.copyWith(color: palette.textSecondary),
      ),
    );
  }
}
