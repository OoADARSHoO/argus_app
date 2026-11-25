import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_palette.dart';

/// Standard card container for Argus.
/// Surface fill, 12px border radius, 20px padding, 1px border, Shadow 1.
/// The surface and border colors come from the active theme.
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
    final palette = context.palette;

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: palette.border,
          width: AppDimensions.borderWidth,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}
