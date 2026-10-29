import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

/// Standard card container for Argus.
/// Surface fill (#16161B), 12px border radius, 20px padding, 1px border (#2A2A33), Shadow 1.
class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPaddingInsets,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.borderWidth,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}
