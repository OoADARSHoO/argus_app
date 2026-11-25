import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_palette.dart';
import '../icons/app_icons.dart';

/// Selectable card for Dark, Light, or System theme options.
/// Shows a mini preview rectangle, label, accent border, and a check badge when selected.
class ThemeOptionCard extends StatelessWidget {
  const ThemeOptionCard({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.preview,
    this.accentColor,
    this.width = AppDimensions.themeCardWidth,
    this.height = AppDimensions.themeCardHeight,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? preview;
  final Color? accentColor;
  final double width;
  final double height;

  /// Previews always show their own theme, never the currently active one.
  /// That is why they use the fixed `AppPalette.dark` / `AppPalette.light`
  /// constants instead of `context.palette`.
  Widget _buildDefaultPreview() {
    final lower = label.toLowerCase();
    if (lower.contains('dark')) {
      return Container(
        decoration: BoxDecoration(
          color: AppPalette.dark.background,
          borderRadius: AppRadius.borderR4,
          border: Border.fromBorderSide(
            BorderSide(
              color: AppPalette.dark.border,
              width: AppDimensions.borderWidth,
            ),
          ),
        ),
      );
    } else if (lower.contains('light')) {
      return Container(
        decoration: BoxDecoration(
          color: AppPalette.light.background,
          borderRadius: AppRadius.borderR4,
          border: Border.fromBorderSide(
            BorderSide(
              color: AppPalette.light.border,
              width: AppDimensions.borderWidth,
            ),
          ),
        ),
      );
    } else {
      // System (split half dark, half light) with a thin border,
      // same size as the Dark and Light previews.
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppPalette.dark.background,
              AppPalette.dark.background,
              AppPalette.light.background,
              AppPalette.light.background,
            ],
            stops: const [0.0, 0.5, 0.5, 1.0],
          ),
          borderRadius: AppRadius.borderR4,
          border: Border.fromBorderSide(
            BorderSide(
              color: AppPalette.dark.border,
              width: AppDimensions.borderWidth,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeAccent = accentColor ?? AppColors.primary;

    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          padding: const EdgeInsets.all(AppSpacing.s8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: isSelected ? activeAccent : palette.border,
              width: AppDimensions.borderWidth,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: preview ?? _buildDefaultPreview(),
                    ),
                    if (isSelected)
                      Positioned(
                        top: AppSpacing.s4,
                        right: AppSpacing.s4,
                        child: Container(
                          width: AppDimensions.themeBadgeSize,
                          height: AppDimensions.themeBadgeSize,
                          decoration: BoxDecoration(
                            color: activeAccent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            AppIcons.check,
                            size: 10,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? palette.textPrimary
                      : palette.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
