import 'package:flutter/widgets.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Centralized icon registry for Argus.
/// Exposes Lucide outline icons matching the design blueprints.
/// Other files must reference [AppIcons] and never import icon packages directly.
class AppIcons {
  AppIcons._();

  static const IconData eye = LucideIcons.eye;
  static const IconData clock = LucideIcons.clock;
  static const IconData settings = LucideIcons.settings;
  static const IconData heart = LucideIcons.heart;
  static const IconData info = LucideIcons.info;
  static const IconData close = LucideIcons.x;
  static const IconData minimize = LucideIcons.minus;
  static const IconData home = LucideIcons.house;
  static const IconData pencil = LucideIcons.pencil;
  static const IconData pause = LucideIcons.pause;
  static const IconData logout = LucideIcons.log_out;
  static const IconData lightbulb = LucideIcons.lightbulb;
  static const IconData check = LucideIcons.check;
  static const IconData chevronDown = LucideIcons.chevron_down;
}
