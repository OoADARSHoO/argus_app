import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../icons/app_icons.dart';

/// Color swatch circle for the Appearance settings.
/// 28px circle. When selected, displays an outer accent ring with a 2px gap
/// and a centered white check mark.
class AccentSwatch extends StatelessWidget {
  const AccentSwatch({
    super.key,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: AppDimensions.accentSwatchTotalSize,
          height: AppDimensions.accentSwatchTotalSize,
          child: Center(
            child: Container(
              width: AppDimensions.accentSwatchTotalSize,
              height: AppDimensions.accentSwatchTotalSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.transparent,
                  width: AppDimensions.accentSwatchRingWidth,
                ),
              ),
              padding: const EdgeInsets.all(AppDimensions.accentSwatchRingGap),
              child: Container(
                width: AppDimensions.accentSwatchSize,
                height: AppDimensions.accentSwatchSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(
                        AppIcons.check,
                        size: AppDimensions.accentSwatchCheckSize,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
