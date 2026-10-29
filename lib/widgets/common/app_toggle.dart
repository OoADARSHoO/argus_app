import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';

/// Toggle switch for Argus.
/// 44x24 track, 20px circular knob.
/// Smoothly animates between inactive (grey track, knob on the LEFT)
/// and active (accent color track, knob on the RIGHT).
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? accentColor;

  bool get isEnabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final activeColor = accentColor ?? AppColors.primary;
    final trackColor = value
        ? (isEnabled ? activeColor : activeColor.withValues(alpha: 0.5))
        : (isEnabled ? AppColors.toggleInactive : AppColors.toggleInactive.withValues(alpha: 0.5));

    final knobColor = isEnabled ? AppColors.white : AppColors.textDisabled;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: AppDimensions.toggleWidth,
          height: AppDimensions.toggleHeight,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: AppRadius.toggleRadius,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.togglePadding),
              child: Container(
                width: AppDimensions.toggleKnobSize,
                height: AppDimensions.toggleKnobSize,
                decoration: BoxDecoration(
                  color: knobColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
