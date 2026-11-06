/// Appearance settings stored in settings.json.
class AppearanceSettings {
  final String themeId;
  final String accentId;
  final int uiScale;

  const AppearanceSettings({
    required this.themeId,
    required this.accentId,
    required this.uiScale,
  });

  static const AppearanceSettings defaults = AppearanceSettings(
    themeId: 'dark',
    accentId: 'blue',
    uiScale: 100,
  );

  AppearanceSettings copyWith({
    String? themeId,
    String? accentId,
    int? uiScale,
  }) {
    return AppearanceSettings(
      themeId: themeId ?? this.themeId,
      accentId: accentId ?? this.accentId,
      uiScale: uiScale ?? this.uiScale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppearanceSettings &&
        other.themeId == themeId &&
        other.accentId == accentId &&
        other.uiScale == uiScale;
  }

  @override
  int get hashCode => Object.hash(themeId, accentId, uiScale);

  Map<String, dynamic> toJson() => {
        'themeId': themeId,
        'accentId': accentId,
        'uiScale': uiScale,
      };

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) {
    try {
      return AppearanceSettings(
        themeId: _safeThemeId(json['themeId'], defaults.themeId),
        accentId: _safeAccentId(json['accentId'], defaults.accentId),
        uiScale: _clampAllowed(
          _safeInt(json['uiScale'], defaults.uiScale),
          _uiScaleOptions,
        ),
      );
    } catch (_) {
      return defaults;
    }
  }

  static const List<int> _uiScaleOptions = [90, 100, 110, 125];
  static const List<String> _themeIds = ['dark', 'light', 'system'];
  static const List<String> _accentIds = [
    'blue',
    'purple',
    'green',
    'orange',
    'pink',
    'teal',
  ];

  /// Returns [value] if it is a known theme id, otherwise [defaultValue].
  static String _safeThemeId(dynamic value, String defaultValue) {
    if (value is String && _themeIds.contains(value)) return value;
    return defaultValue;
  }

  /// Returns [value] if it is a known accent id, otherwise [defaultValue].
  static String _safeAccentId(dynamic value, String defaultValue) {
    if (value is String && _accentIds.contains(value)) return value;
    return defaultValue;
  }

  static int _safeInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is double) return value.round();
    return defaultValue;
  }

  /// Clamp [value] to the nearest allowed dropdown option.
  static int _clampAllowed(int value, List<int> allowed) {
    if (allowed.contains(value)) return value;
    if (allowed.isEmpty) return value;
    return allowed.reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);
  }
}
