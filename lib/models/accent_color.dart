import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Accent color options for Argus.
/// Defined in the Appearance settings order: Blue, Purple, Green, Orange, Pink, Teal.
/// Each option has a stable string [id] used for saving to settings.json.
class AccentColorOption {
  final String id;
  final String name;
  final Color color;

  const AccentColorOption({
    required this.id,
    required this.name,
    required this.color,
  });

  AccentColorOption copyWith({
    String? id,
    String? name,
    Color? color,
  }) {
    return AccentColorOption(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccentColorOption &&
        other.id == id &&
        other.name == name &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, name, color);

  static const AccentColorOption blue = AccentColorOption(
    id: 'blue',
    name: 'Blue',
    color: AppColors.accentBlue,
  );

  static const AccentColorOption purple = AccentColorOption(
    id: 'purple',
    name: 'Purple',
    color: AppColors.accentPurple,
  );

  static const AccentColorOption green = AccentColorOption(
    id: 'green',
    name: 'Green',
    color: AppColors.accentGreen,
  );

  static const AccentColorOption orange = AccentColorOption(
    id: 'orange',
    name: 'Orange',
    color: AppColors.accentOrange,
  );

  static const AccentColorOption pink = AccentColorOption(
    id: 'pink',
    name: 'Pink',
    color: AppColors.accentPink,
  );

  static const AccentColorOption teal = AccentColorOption(
    id: 'teal',
    name: 'Teal',
    color: AppColors.accentTeal,
  );

  static const List<AccentColorOption> all = [
    blue,
    purple,
    green,
    orange,
    pink,
    teal,
  ];

  /// Look up an accent option by its stable string id.
  /// Falls back to [blue] if the id is unknown, null, or empty.
  static AccentColorOption fromId(String? id) {
    if (id == null || id.isEmpty) return blue;
    try {
      return all.firstWhere((opt) => opt.id == id);
    } catch (_) {
      return blue;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  static AccentColorOption fromJson(Map<String, dynamic>? json) {
    if (json == null) return blue;
    return fromId(json['id'] as String?);
  }
}
