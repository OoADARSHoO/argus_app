import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/accent_color.dart';
import '../../services/settings_service.dart';
import '../../widgets/common/accent_swatch.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/settings_row.dart';
import '../../widgets/common/theme_option_card.dart';

/// Appearance settings page in Argus.
/// Allows selecting themes, accent colors, and UI scaling.
class AppearancePage extends StatelessWidget {
  const AppearancePage({
    super.key,
    required this.settings,
  });

  final SettingsService settings;

  static const List<MapEntry<int, String>> uiScaleOptions = [
    MapEntry(90, '90%'),
    MapEntry(100, '100% (Default)'),
    MapEntry(110, '110%'),
    MapEntry(125, '125%'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = settings.settings.appearanceSettings;
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
                isSelected: s.themeId == 'dark',
                accentColor: settings.accentColor,
                onTap: () => settings.update(
                  settings.settings.copyWith(
                    appearanceSettings: s.copyWith(themeId: 'dark'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              ThemeOptionCard(
                label: 'Light',
                isSelected: s.themeId == 'light',
                accentColor: settings.accentColor,
                onTap: () => settings.update(
                  settings.settings.copyWith(
                    appearanceSettings: s.copyWith(themeId: 'light'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              ThemeOptionCard(
                label: 'System',
                isSelected: s.themeId == 'system',
                accentColor: settings.accentColor,
                onTap: () => settings.update(
                  settings.settings.copyWith(
                    appearanceSettings: s.copyWith(themeId: 'system'),
                  ),
                ),
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
                  isSelected: s.accentId == opt.id,
                  onTap: () => settings.update(
                    settings.settings.copyWith(
                      appearanceSettings: s.copyWith(accentId: opt.id),
                    ),
                  ),
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
          control: AppDropdown<int>(
            value: s.uiScale,
            width: AppDimensions.dropdownWidth,
            items: uiScaleOptions
                .map((opt) => AppDropdownItem(value: opt.key, label: opt.value))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                settings.update(
                  settings.settings.copyWith(
                    appearanceSettings: s.copyWith(uiScale: val),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
