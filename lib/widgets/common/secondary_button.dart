import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Secondary action button for Argus.
/// 40px high, transparent fill with 1px border, rounded corners (r6), with hover/pressed states.
/// When [onPressed] is null, renders in disabled state using textDisabled.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;

  bool get isEnabled => onPressed != null;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.isEnabled;

    final Color backgroundColor;
    final Color borderColor;
    final Color foregroundColor;

    if (!isEnabled) {
      backgroundColor = AppColors.transparent;
      borderColor = AppColors.border;
      foregroundColor = AppColors.textDisabled;
    } else if (_isPressed) {
      backgroundColor = AppColors.border;
      borderColor = AppColors.border;
      foregroundColor = widget.textColor ?? AppColors.textPrimary;
    } else if (_isHovered) {
      backgroundColor = AppColors.surfaceElevated;
      borderColor = AppColors.border;
      foregroundColor = widget.textColor ?? AppColors.textPrimary;
    } else {
      backgroundColor = AppColors.transparent;
      borderColor = AppColors.border;
      foregroundColor = widget.textColor ?? AppColors.textPrimary;
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
            border: Border.all(
              color: borderColor,
              width: AppDimensions.borderWidth,
            ),
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
