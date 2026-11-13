import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../services/settings_service.dart';
import '../../services/update_service.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/app_toggle.dart';
import '../../widgets/common/settings_row.dart';

/// General settings page in Argus.
/// Allows configuring break intervals, durations, skipping, startup, and notifications.
class GeneralPage extends StatelessWidget {
  const GeneralPage({
    super.key,
    required this.settings,
    required this.updateService,
  });

  final SettingsService settings;
  final UpdateService updateService;

  static const List<MapEntry<int, String>> intervalOptions = [
    MapEntry(5, '5 minutes'),
    MapEntry(10, '10 minutes'),
    MapEntry(15, '15 minutes'),
    MapEntry(20, '20 minutes'),
    MapEntry(30, '30 minutes'),
    MapEntry(45, '45 minutes'),
    MapEntry(60, '60 minutes'),
  ];

  static const List<MapEntry<int, String>> durationOptions = [
    MapEntry(10, '10 seconds'),
    MapEntry(20, '20 seconds'),
    MapEntry(30, '30 seconds'),
    MapEntry(60, '60 seconds'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = settings.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header
        const Text(
          'General',
          style: AppTypography.heading2,
        ),
        const SizedBox(height: AppSpacing.s4),
        const Text(
          'Configure general behavior of Argus.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s24),

        // Settings rows
        SettingsRow(
          label: 'Break Interval',
          description: 'Time between breaks',
          control: AppDropdown<int>(
            value: s.breakIntervalMinutes,
            width: AppDimensions.dropdownWidth,
            items: intervalOptions
                .map((opt) => AppDropdownItem(value: opt.key, label: opt.value))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                settings.update(s.copyWith(breakIntervalMinutes: val));
              }
            },
          ),
        ),
        SettingsRow(
          label: 'Break Duration',
          description: 'Length of each break',
          control: AppDropdown<int>(
            value: s.breakDurationSeconds,
            width: AppDimensions.dropdownWidth,
            items: durationOptions
                .map((opt) => AppDropdownItem(value: opt.key, label: opt.value))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                settings.update(s.copyWith(breakDurationSeconds: val));
              }
            },
          ),
        ),
        SettingsRow(
          label: 'Skip Option',
          description: 'Allow skipping break with Esc key',
          control: AppToggle(
            value: s.skipEnabled,
            accentColor: settings.accentColor,
            onChanged: (val) => settings.update(s.copyWith(skipEnabled: val)),
          ),
        ),
        SettingsRow(
          label: 'Start on Windows Startup',
          description: 'Launch Argus when Windows starts',
          control: AppToggle(
            value: s.startOnStartup,
            accentColor: settings.accentColor,
            onChanged: (val) => settings.update(s.copyWith(startOnStartup: val)),
          ),
        ),
        SettingsRow(
          label: 'Show Notifications',
          description: 'Show reminder before break (10 sec before)',
          control: AppToggle(
            value: s.showNotifications,
            accentColor: settings.accentColor,
            onChanged: (val) =>
                settings.update(s.copyWith(showNotifications: val)),
          ),
        ),
        SettingsRow(
          label: 'Enable Sounds',
          description: 'Play a soft sound before a break',
          showDivider: false,
          control: AppToggle(
            value: s.enableSounds,
            accentColor: settings.accentColor,
            onChanged: (val) => settings.update(s.copyWith(enableSounds: val)),
          ),
        ),
        SettingsRow(
          label: 'Check for updates automatically',
          description: 'Checks GitHub for new versions of Argus',
          control: AppToggle(
            value: s.autoUpdate,
            accentColor: settings.accentColor,
            onChanged: (val) => settings.update(s.copyWith(autoUpdate: val)),
          ),
        ),
      ],
    );
  }
}
