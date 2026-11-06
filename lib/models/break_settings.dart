/// Break screen settings stored in settings.json.
/// Numeric values are stored as raw numbers, not display strings.
class BreakSettings {
  final String message;
  final String backgroundId;
  final int textColor;
  final String fontSizeId;
  final bool showProgressRing;

  const BreakSettings({
    required this.message,
    required this.backgroundId,
    required this.textColor,
    required this.fontSizeId,
    required this.showProgressRing,
  });

  static const BreakSettings defaults = BreakSettings(
    message: 'Time to rest your eyes. Look at something 20 feet away for 20 seconds.',
    backgroundId: 'black_screen',
    textColor: 0xFFF5F5F5,
    fontSizeId: 'large',
    showProgressRing: true,
  );

  BreakSettings copyWith({
    String? message,
    String? backgroundId,
    int? textColor,
    String? fontSizeId,
    bool? showProgressRing,
  }) {
    return BreakSettings(
      message: message ?? this.message,
      backgroundId: backgroundId ?? this.backgroundId,
      textColor: textColor ?? this.textColor,
      fontSizeId: fontSizeId ?? this.fontSizeId,
      showProgressRing: showProgressRing ?? this.showProgressRing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreakSettings &&
        other.message == message &&
        other.backgroundId == backgroundId &&
        other.textColor == textColor &&
        other.fontSizeId == fontSizeId &&
        other.showProgressRing == showProgressRing;
  }

  @override
  int get hashCode =>
      Object.hash(message, backgroundId, textColor, fontSizeId, showProgressRing);

  Map<String, dynamic> toJson() => {
        'message': message,
        'backgroundId': backgroundId,
        'textColor': textColor,
        'fontSizeId': fontSizeId,
        'showProgressRing': showProgressRing,
      };

  factory BreakSettings.fromJson(Map<String, dynamic> json) {
    try {
      return BreakSettings(
        message: _safeString(json['message'], defaults.message),
        backgroundId: _safeBackgroundId(json['backgroundId'], defaults.backgroundId),
        textColor: _safeInt(json['textColor'], defaults.textColor),
        fontSizeId: _safeFontSizeId(json['fontSizeId'], defaults.fontSizeId),
        showProgressRing: _safeBool(json['showProgressRing'], defaults.showProgressRing),
      );
    } catch (_) {
      return defaults;
    }
  }

  static const List<String> _backgroundIds = [
    'black_screen',
    'dark_gray',
    'deep_blue',
  ];
  static const List<String> _fontSizeIds = ['small', 'medium', 'large'];

  static String _safeString(dynamic value, String defaultValue) {
    if (value is String && value.isNotEmpty) return value;
    return defaultValue;
  }

  /// Returns [value] if it is a known background id, otherwise [defaultValue].
  static String _safeBackgroundId(dynamic value, String defaultValue) {
    if (value is String && _backgroundIds.contains(value)) return value;
    return defaultValue;
  }

  /// Returns [value] if it is a known font size id, otherwise [defaultValue].
  static String _safeFontSizeId(dynamic value, String defaultValue) {
    if (value is String && _fontSizeIds.contains(value)) return value;
    return defaultValue;
  }

  static int _safeInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is double) return value.round();
    return defaultValue;
  }

  static bool _safeBool(dynamic value, bool defaultValue) {
    if (value is bool) return value;
    return defaultValue;
  }
}
