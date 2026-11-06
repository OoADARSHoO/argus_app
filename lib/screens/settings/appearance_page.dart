import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/accent_color.dart';
import '../../widgets/common/accent_swatch.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/settings_row.dart';
import '../../widgets/common/theme_option_card.dart';
import 'settings_shell.dart';

/// Appearance settings page in Argus.
/// Allows selecting themes, accent colors, and UI scaling.
class AppearancePage extends StatelessWidget {
  const AppearancePage({
    super.key,
    required this.settings,
  });

  final TempSettingsState settings;

  static const List<String> uiScaleOptions = [
    '90%',
    '100% (Default)',
    '110%',
    '125%',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header
        const Text(
          'Appearance',
          style: AppTypography.heading2,
        ),
        const SizedBox(height: AppSpacing.s4),
        const Text(
          'Change how Argus looks.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s24),

        // Theme option cards
        SettingsRow(
          label: 'Theme',
          description: 'Choose your preferred theme',
          vertical: true,
          control: Row(
            children: [
              ThemeOptionCard(
                label: 'Dark',
                isSelected: settings.selectedTheme == 'Dark',
                accentColor: settings.selectedAccentColor,
                onTap: () => settings.setSelectedTheme('Dark'),
              ),
              const SizedBox(width: AppSpacing.s12),
              ThemeOptionCard(
                label: 'Light',
                isSelected: settings.selectedTheme == 'Light',
                accentColor: settings.selectedAccentColor,
                onTap: () => settings.setSelectedTheme('Light'),
              ),
              const SizedBox(width: AppSpacing.s12),
              ThemeOptionCard(
                label: 'System',
                isSelected: settings.selectedTheme == 'System',
                accentColor: settings.selectedAccentColor,
                onTap: () => settings.setSelectedTheme('System'),
              ),
            ],
          ),
        ),

        // Accent color swatches
        SettingsRow(
          label: 'Accent Color',
          description: 'Choose accent color',
          vertical: true,
          control: Row(
            children: AccentColorOption.all.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s8),
                child: AccentSwatch(
                  color: opt.color,
                  isSelected: settings.selectedAccentColor == opt.color,
                  onTap: () => settings.setSelectedAccentColor(opt.color),
                ),
              );
            }).toList(),
          ),
        ),

        // UI Scale dropdown
        SettingsRow(
          label: 'UI Scale',
          description: 'Adjust the size of UI elements',
          showDivider: false,
          control: AppDropdown<String>(
            value: settings.uiScale,
            width: AppDimensions.dropdownWidth,
            items: uiScaleOptions
                .map((opt) => AppDropdownItem(value: opt, label: opt))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setUiScale(val);
            },
          ),
        ),
      ],
    );
  }
}
