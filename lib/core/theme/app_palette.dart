import 'package:flutter/material.dart';

/// Theme-dependent color tokens for Argus.
///
/// Why a [ThemeExtension]: the settings UI has a dark and a light theme, and
/// widgets need to read the active colors from the theme instead of using one
/// hard-coded palette. [AppPalette.dark] holds the exact values the app used
/// before Phase 13E, so the dark theme looks unchanged.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.toggleInactive,
    required this.warningText,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color toggleInactive;

  /// Amber for small warning text.
  ///
  /// [AppColors.warning] is a status color and stays the same in both themes,
  /// but it is too bright to read as small text on a light surface. The light
  /// palette therefore uses a darker amber of the same hue here.
  final Color warningText;

  /// The original dark palette. These values must stay identical to the
  /// pre-Phase 13E dark theme.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0E0E10),
    surface: Color(0xFF16161B),
    surfaceElevated: Color(0xFF1E1E24),
    border: Color(0xFF2A2A33),
    divider: Color(0xFF24242C),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA1A1AA),
    textTertiary: Color(0xFF71717A),
    textDisabled: Color(0xFF52525B),
    toggleInactive: Color(0xFF3F3F46),
    warningText: Color(0xFFF59E0B),
  );

  /// Light palette for the whole settings window.
  ///
  /// [textTertiary] is slightly darker than the first proposal (#71717A) so
  /// hint text still reaches WCAG AA (4.5:1) on [surfaceElevated]. The other
  /// values match the agreed light palette.
  static const AppPalette light = AppPalette(
    background: Color(0xFFF7F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F0F4),
    border: Color(0xFFE1E1E8),
    divider: Color(0xFFEBEBF0),
    textPrimary: Color(0xFF18181B),
    textSecondary: Color(0xFF52525B),
    textTertiary: Color(0xFF6B6B73),
    textDisabled: Color(0xFFA1A1AA),
    toggleInactive: Color(0xFFD4D4D8),
    warningText: Color(0xFF92400E),
  );

  bool get _isLight => background.computeLuminance() > 0.5;

  /// Returns [accent] as a text or icon foreground that is readable on this
  /// palette.
  ///
  /// Dark mode keeps the accent exactly as designed. Light mode blends it
  /// toward black because the six brand accents are tuned for a dark
  /// background and would otherwise be too faint on white.
  Color accentText(Color accent) {
    if (!_isLight) return accent;
    return Color.alphaBlend(Colors.black.withValues(alpha: 0.40), accent);
  }

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? toggleInactive,
    Color? warningText,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      toggleInactive: toggleInactive ?? this.toggleInactive,
      warningText: warningText ?? this.warningText,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      toggleInactive: Color.lerp(toggleInactive, other.toggleInactive, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
    );
  }
}

/// Reads the active palette from the current theme.
///
/// The fallback keeps widgets usable in tests and simple `MaterialApp`s that
/// do not install the Argus theme. It also means a future theme cannot crash
/// the UI by forgetting the extension.
extension AppPaletteContext on BuildContext {
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}
