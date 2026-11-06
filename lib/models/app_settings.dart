import 'break_settings.dart';
import 'appearance_settings.dart';

/// Top-level settings model for Argus.
/// Stored as JSON at %APPDATA%\Argus\settings.json.
class AppSettings {
  final int breakIntervalMinutes;
  final int breakDurationSeconds;
  final bool skipEnabled;
  final bool startOnStartup;
  final bool showNotifications;
  final bool enableSounds;
  final BreakSettings breakSettings;
  final AppearanceSettings appearanceSettings;

  const AppSettings({
    required this.breakIntervalMinutes,
    required this.breakDurationSeconds,
    required this.skipEnabled,
    required this.startOnStartup,
    required this.showNotifications,
    required this.enableSounds,
    required this.breakSettings,
    required this.appearanceSettings,
  });

  static const AppSettings defaults = AppSettings(
    breakIntervalMinutes: 20,
    breakDurationSeconds: 20,
    skipEnabled: true,
    startOnStartup: true,
    showNotifications: true,
    enableSounds: false,
    breakSettings: BreakSettings.defaults,
    appearanceSettings: AppearanceSettings.defaults,
  );

  AppSettings copyWith({
    int? breakIntervalMinutes,
    int? breakDurationSeconds,
    bool? skipEnabled,
    bool? startOnStartup,
    bool? showNotifications,
    bool? enableSounds,
    BreakSettings? breakSettings,
    AppearanceSettings? appearanceSettings,
  }) {
    return AppSettings(
      breakIntervalMinutes: breakIntervalMinutes ?? this.breakIntervalMinutes,
      breakDurationSeconds: breakDurationSeconds ?? this.breakDurationSeconds,
      skipEnabled: skipEnabled ?? this.skipEnabled,
      startOnStartup: startOnStartup ?? this.startOnStartup,
      showNotifications: showNotifications ?? this.showNotifications,
      enableSounds: enableSounds ?? this.enableSounds,
      breakSettings: breakSettings ?? this.breakSettings,
      appearanceSettings: appearanceSettings ?? this.appearanceSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.breakIntervalMinutes == breakIntervalMinutes &&
        other.breakDurationSeconds == breakDurationSeconds &&
        other.skipEnabled == skipEnabled &&
        other.startOnStartup == startOnStartup &&
        other.showNotifications == showNotifications &&
        other.enableSounds == enableSounds &&
        other.breakSettings == breakSettings &&
        other.appearanceSettings == appearanceSettings;
  }

  @override
  int get hashCode => Object.hash(
    breakIntervalMinutes,
    breakDurationSeconds,
    skipEnabled,
    startOnStartup,
    showNotifications,
    enableSounds,
    breakSettings,
    appearanceSettings,
  );

  Map<String, dynamic> toJson() => {
        'version': 1,
        'breakIntervalMinutes': breakIntervalMinutes,
        'breakDurationSeconds': breakDurationSeconds,
        'skipEnabled': skipEnabled,
        'startOnStartup': startOnStartup,
        'showNotifications': showNotifications,
        'enableSounds': enableSounds,
        'breakSettings': breakSettings.toJson(),
        'appearanceSettings': appearanceSettings.toJson(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    try {
      if (json['version'] != 1) {
        // Unknown format version — return defaults for safe migration later.
        return defaults;
      }
      return AppSettings(
        breakIntervalMinutes: _clampAllowed(
          _safeInt(json['breakIntervalMinutes'], defaults.breakIntervalMinutes),
          _intervalOptions,
        ),
        breakDurationSeconds: _clampAllowed(
          _safeInt(json['breakDurationSeconds'], defaults.breakDurationSeconds),
          _durationOptions,
        ),
        skipEnabled: _safeBool(json['skipEnabled'], defaults.skipEnabled),
        startOnStartup: _safeBool(json['startOnStartup'], defaults.startOnStartup),
        showNotifications:
            _safeBool(json['showNotifications'], defaults.showNotifications),
        enableSounds: _safeBool(json['enableSounds'], defaults.enableSounds),
        breakSettings: BreakSettings.fromJson(
          (json['breakSettings'] as Map<String, dynamic>?) ?? {},
        ),
        appearanceSettings: AppearanceSettings.fromJson(
          (json['appearanceSettings'] as Map<String, dynamic>?) ?? {},
        ),
      );
    } catch (_) {
      return defaults;
    }
  }

  static const List<int> _intervalOptions = [5, 10, 15, 20, 30, 45, 60];
  static const List<int> _durationOptions = [10, 20, 30, 60];

  static int _safeInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is double) return value.round();
    return defaultValue;
  }

  static bool _safeBool(dynamic value, bool defaultValue) {
    if (value is bool) return value;
    return defaultValue;
  }

  /// Clamp [value] to the nearest allowed dropdown option.
  static int _clampAllowed(int value, List<int> allowed) {
    if (allowed.contains(value)) return value;
    if (allowed.isEmpty) return value;
    return allowed.reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);
  }
}
