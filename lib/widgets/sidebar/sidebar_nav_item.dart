import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_palette.dart';

/// Single item within the sidebar navigation.
/// 160px wide by 40px high.
/// Active item: accent color at 12-15% opacity as background, accent-colored icon & text.
/// Inactive item: textSecondary, hover shows surfaceElevated.
class SidebarNavItem extends StatefulWidget {
  const SidebarNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeAccent = widget.accentColor ?? AppColors.primary;

    final Color backgroundColor;
    final Color foregroundColor;

    if (widget.isSelected) {
      backgroundColor = activeAccent.withValues(alpha: AppColors.activeOpacity);
      // Light mode needs a darker version of the accent to stay readable.
      foregroundColor = palette.accentText(activeAccent);
    } else if (_isHovered) {
      backgroundColor = palette.surfaceElevated;
      foregroundColor = palette.textPrimary;
    } else {
      backgroundColor = AppColors.transparent;
      foregroundColor = palette.textSecondary;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: AppDimensions.sidebarItemWidth,
          height: AppDimensions.sidebarItemHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.buttonRadius,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: AppDimensions.sidebarIconSize,
                color: foregroundColor,
              ),
              const SizedBox(width: AppSpacing.iconToText),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: foregroundColor,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
