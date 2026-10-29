import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
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

  Widget _buildDefaultPreview() {
    final lower = label.toLowerCase();
    if (lower.contains('dark')) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.borderR4,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.border, width: AppDimensions.borderWidth),
          ),
        ),
      );
    } else if (lower.contains('light')) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: AppRadius.borderR4,
        ),
      );
    } else {
      // System (split half dark, half light)
      return ClipRRect(
        borderRadius: AppRadius.borderR4,
        child: Row(
          children: const [
            Expanded(
              child: ColoredBox(color: AppColors.background),
            ),
            Expanded(
              child: ColoredBox(color: AppColors.textPrimary),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: isSelected ? activeAccent : AppColors.border,
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
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
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
