import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/app_text_input.dart';
import '../../widgets/common/app_toggle.dart';
import '../../widgets/common/settings_row.dart';
import '../../widgets/icons/app_icons.dart';
import 'settings_shell.dart';

/// Break customization settings page in Argus.
/// Allows setting the break message, background screen, text color, font size, and progress ring.
class BreakPage extends StatelessWidget {
  const BreakPage({
    super.key,
    required this.settings,
  });

  final TempSettingsState settings;

  static const List<String> backgroundOptions = [
    'Black Screen',
    'Dark Gray',
    'Deep Blue',
  ];

  static const List<String> fontSizeOptions = [
    'Small',
    'Medium',
    'Large',
  ];

  static const List<TextColorOption> textColorOptions = [
    TextColorOption(name: 'Pure White', color: AppColors.white),
    TextColorOption(name: 'Off-White (Default)', color: Color(0xFFF5F5F5)),
    TextColorOption(name: 'Soft Amber', color: Color(0xFFFEF3C7)),
    TextColorOption(name: 'Ice Blue', color: Color(0xFFE0F2FE)),
    TextColorOption(name: 'Soft Mint', color: Color(0xFFD1FAE5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header
        const Text(
          'Break',
          style: AppTypography.heading2,
        ),
        const SizedBox(height: AppSpacing.s4),
        const Text(
          'Customize your break experience.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s24),

        // Settings rows
        SettingsRow(
          label: 'Break Message',
          description: 'Message shown during break',
          control: AppTextInput(
            initialValue: settings.breakMessage,
            multiline: true,
            minLines: 3,
            maxLines: 4,
            width: AppDimensions.breakMessageInputWidth,
            onChanged: (val) => settings.setBreakMessage(val),
          ),
        ),
        SettingsRow(
          label: 'Background',
          description: 'What to show during break',
          control: AppDropdown<String>(
            value: settings.breakBackground,
            width: AppDimensions.dropdownWidth,
            items: backgroundOptions
                .map((opt) => AppDropdownItem(value: opt, label: opt))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setBreakBackground(val);
            },
          ),
        ),
        SettingsRow(
          label: 'Text Color',
          description: 'Color of the message',
          control: _TextColorPicker(
            currentColor: settings.textColor,
            options: textColorOptions,
            onColorChanged: (c) => settings.setTextColor(c),
          ),
        ),
        SettingsRow(
          label: 'Font Size',
          description: 'Adjust message size',
          control: AppDropdown<String>(
            value: settings.fontSize,
            width: AppDimensions.dropdownWidth,
            items: fontSizeOptions
                .map((opt) => AppDropdownItem(value: opt, label: opt))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setFontSize(val);
            },
          ),
        ),
        SettingsRow(
          label: 'Show Progress Ring',
          description: 'Display countdown ring',
          showDivider: false,
          control: AppToggle(
            value: settings.showProgressRing,
            accentColor: settings.selectedAccentColor,
            onChanged: (val) => settings.setShowProgressRing(val),
          ),
        ),
      ],
    );
  }
}

class TextColorOption {
  const TextColorOption({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;
}

class _TextColorPicker extends StatelessWidget {
  const _TextColorPicker({
    required this.currentColor,
    required this.options,
    required this.onColorChanged,
  });

  final Color currentColor;
  final List<TextColorOption> options;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Color>(
      tooltip: 'Choose text color',
      color: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderR8,
        side: BorderSide(
          color: AppColors.border,
          width: AppDimensions.borderWidth,
        ),
      ),
      initialValue: currentColor,
      onSelected: onColorChanged,
      itemBuilder: (context) {
        return options.map((opt) {
          final isSelected = opt.color == currentColor;
          return PopupMenuItem<Color>(
            value: opt.color,
            child: Row(
              children: [
                Container(
                  width: AppDimensions.iconSizeSmall,
                  height: AppDimensions.iconSizeSmall,
                  decoration: BoxDecoration(
                    color: opt.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimensions.borderWidth,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    opt.name,
                    style: AppTypography.body.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    AppIcons.check,
                    size: AppDimensions.iconSizeSmall,
                    color: AppColors.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        width: AppDimensions.textColorSwatchWidth,
        height: AppDimensions.textColorSwatchHeight,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: AppRadius.borderR4,
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.borderWidth,
          ),
        ),
      ),
    );
  }
}
