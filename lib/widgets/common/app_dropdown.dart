import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../icons/app_icons.dart';

/// Item model for [AppDropdown].
class AppDropdownItem<T> {
  const AppDropdownItem({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

/// Dropdown selector for Argus.
/// 36px high, surfaceElevated background, 1px border.
/// The selected value is left-aligned with the chevron pinned to the far right.
/// Popup menu is styled for the dark aesthetic.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = AppDimensions.dropdownWidth,
  });

  final T value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double? width;

  bool get isEnabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.dropdownHeight,
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPaddingHorizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.inputRadius,
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.borderWidth,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          isDense: true,
          dropdownColor: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderR8,
          alignment: AlignmentDirectional.centerStart,
          icon: const Icon(
            AppIcons.chevronDown,
            size: AppDimensions.iconSizeSmall,
            color: AppColors.textSecondary,
          ),
          style: AppTypography.body,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                item.label,
                style: AppTypography.body.copyWith(
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
