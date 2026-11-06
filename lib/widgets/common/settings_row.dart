import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// A standard row in the settings pages.
/// Displays a title (Body SemiBold) and description (Caption, textSecondary) on the left,
/// a control widget on the right, and a 1px divider below.
/// Supports both horizontal layout (standard) and vertical layout (for Theme & Accent swatches).
/// Minimum height is 64px.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.description,
    required this.control,
    this.showDivider = true,
    this.vertical = false,
  });

  final String label;
  final String description;
  final Widget control;
  final bool showDivider;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final border = showDivider
        ? const Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: AppDimensions.borderWidth,
            ),
          )
        : null;

    if (vertical) {
      return Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.settingsRowMinHeight,
        ),
        padding: AppSpacing.settingsRowPadding,
        decoration: BoxDecoration(border: border),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppTypography.bodySemibold),
            const SizedBox(height: AppSpacing.s4),
            Text(description, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.s12),
            control,
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.settingsRowMinHeight,
      ),
      padding: AppSpacing.settingsRowPadding,
      decoration: BoxDecoration(border: border),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySemibold,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  description,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          control,
        ],
      ),
    );
  }
}
