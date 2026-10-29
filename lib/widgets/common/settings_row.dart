import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// A standard row in the settings pages.
/// Displays a title (Body SemiBold) and description (Caption, textSecondary) on the left,
/// a control widget on the right, and a 1px divider below.
/// Minimum height is 64px.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.description,
    required this.control,
    this.showDivider = true,
  });

  final String label;
  final String description;
  final Widget control;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.settingsRowMinHeight,
      ),
      padding: AppSpacing.settingsRowPadding,
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: AppDimensions.borderWidth,
                ),
              )
            : null,
      ),
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
