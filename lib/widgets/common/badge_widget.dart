import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_palette.dart';

/// Small badge tag for Argus (e.g., "NEW").
/// 18px high, 8px corner radius, with low-opacity accent background and accent text.
class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    super.key,
    required this.text,
    this.accentColor,
  });

  final String text;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveColor = accentColor ?? AppColors.primary;

    return Container(
      height: AppDimensions.badgeHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.badgePaddingHorizontal,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: AppColors.activeOpacity),
        borderRadius: AppRadius.badgeRadius,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTypography.badge.copyWith(
          color: palette.accentText(effectiveColor),
        ),
      ),
    );
  }
}
