import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';

/// Icon button for Argus.
/// 40x40 container with a 24px icon.
/// Highlights with `surfaceElevated` on hover, and dims to `textDisabled` when disabled.
class IconButtonWidget extends StatefulWidget {
  const IconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.tooltip,
    this.size = AppDimensions.iconButtonSize,
    this.iconSize = AppDimensions.iconSize,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final String? tooltip;
  final double size;
  final double iconSize;

  bool get isEnabled => onPressed != null;

  @override
  State<IconButtonWidget> createState() => _IconButtonWidgetState();
}

class _IconButtonWidgetState extends State<IconButtonWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;

    final Color backgroundColor;
    final Color foregroundColor;

    if (!isEnabled) {
      backgroundColor = AppColors.transparent;
      foregroundColor = AppColors.textDisabled;
    } else if (_isPressed) {
      backgroundColor = AppColors.border;
      foregroundColor = widget.iconColor ?? AppColors.textPrimary;
    } else if (_isHovered) {
      backgroundColor = AppColors.surfaceElevated;
      foregroundColor = widget.iconColor ?? AppColors.textPrimary;
    } else {
      backgroundColor = AppColors.transparent;
      foregroundColor = widget.iconColor ?? AppColors.textPrimary;
    }

    Widget button = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isEnabled) {
          setState(() {
            _isHovered = false;
            _isPressed = false;
          });
        }
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (isEnabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (isEnabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (isEnabled) setState(() => _isPressed = false);
        },
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.buttonRadius,
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: foregroundColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
