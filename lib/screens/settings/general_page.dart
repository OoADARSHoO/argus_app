import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/app_toggle.dart';
import '../../widgets/common/settings_row.dart';
import 'settings_shell.dart';

/// General settings page in Argus.
/// Allows configuring break intervals, durations, skipping, startup, and notifications.
class GeneralPage extends StatelessWidget {
  const GeneralPage({
    super.key,
    required this.settings,
  });

  final TempSettingsState settings;

  static const List<String> intervalOptions = [
    '5 minutes',
    '10 minutes',
    '15 minutes',
    '20 minutes',
    '30 minutes',
    '45 minutes',
    '60 minutes',
  ];

  static const List<String> durationOptions = [
    '10 seconds',
    '20 seconds',
    '30 seconds',
    '60 seconds',
  ];

  @override
  Widget build(BuildContext context) {
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
          control: AppDropdown<String>(
            value: settings.breakInterval,
            width: AppDimensions.dropdownWidth,
            items: intervalOptions
                .map((opt) => AppDropdownItem(value: opt, label: opt))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setBreakInterval(val);
            },
          ),
        ),
        SettingsRow(
          label: 'Break Duration',
          description: 'Length of each break',
          control: AppDropdown<String>(
            value: settings.breakDuration,
            width: AppDimensions.dropdownWidth,
            items: durationOptions
                .map((opt) => AppDropdownItem(value: opt, label: opt))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setBreakDuration(val);
            },
          ),
        ),
        SettingsRow(
          label: 'Skip Option',
          description: 'Allow skipping break with Esc key',
          control: AppToggle(
            value: settings.skipOption,
            accentColor: settings.selectedAccentColor,
            onChanged: (val) => settings.setSkipOption(val),
          ),
        ),
        SettingsRow(
          label: 'Start on Windows Startup',
          description: 'Launch Argus when Windows starts',
          control: AppToggle(
            value: settings.startOnStartup,
            accentColor: settings.selectedAccentColor,
            onChanged: (val) => settings.setStartOnStartup(val),
          ),
        ),
        SettingsRow(
          label: 'Show Notifications',
          description: 'Show reminder before break (10 sec before)',
          control: AppToggle(
            value: settings.showNotifications,
            accentColor: settings.selectedAccentColor,
            onChanged: (val) => settings.setShowNotifications(val),
          ),
        ),
        SettingsRow(
          label: 'Enable Sounds',
          description: 'Play a soft sound before a break',
          showDivider: false,
          control: AppToggle(
            value: settings.enableSounds,
            accentColor: settings.selectedAccentColor,
            onChanged: (val) => settings.setEnableSounds(val),
          ),
        ),
      ],
    );
  }
}
