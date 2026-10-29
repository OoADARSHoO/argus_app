import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Primary action button for Argus.
/// 40px high, filled with accent color, rounded corners (r6), with hover/pressed states.
/// When [onPressed] is null, renders in disabled state using textDisabled.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  bool get isEnabled => onPressed != null;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;
    final baseColor = widget.color ?? AppColors.primary;

    final Color backgroundColor;
    final Color foregroundColor;

    if (!isEnabled) {
      backgroundColor = AppColors.surfaceElevated;
      foregroundColor = AppColors.textDisabled;
    } else if (_isPressed) {
      backgroundColor = AppColors.primaryDark;
      foregroundColor = widget.textColor ?? AppColors.white;
    } else if (_isHovered) {
      backgroundColor = AppColors.primaryLight;
      foregroundColor = widget.textColor ?? AppColors.white;
    } else {
      backgroundColor = baseColor;
      foregroundColor = widget.textColor ?? AppColors.white;
    }

    return MouseRegion(
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
          height: AppDimensions.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.buttonRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: AppDimensions.iconSizeSmall,
                  color: foregroundColor,
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              Text(
                widget.label,
                style: AppTypography.button.copyWith(color: foregroundColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
