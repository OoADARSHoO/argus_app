import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../icons/app_icons.dart';

/// Custom frameless title bar for Argus.
/// 32px high with draggable window area, "ARGUS" wordmark on the left,
/// and minimize and close buttons on the right.
class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({
    super.key,
    this.onMinimize,
    this.onClose,
  });

  final VoidCallback? onMinimize;
  final VoidCallback? onClose;

  Future<void> _handleMinimize() async {
    if (onMinimize != null) {
      onMinimize!();
    } else {
      await windowManager.minimize();
    }
  }

  Future<void> _handleClose() async {
    if (onClose != null) {
      onClose!();
    } else {
      await windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.titleBarHeight,
      color: AppColors.background,
      child: Row(
        children: [
          // Wordmark area (also draggable)
          DragToMoveArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'ARGUS',
                style: AppTypography.titleBarWordmark,
              ),
            ),
          ),

          // Central empty draggable area
          Expanded(
            child: DragToMoveArea(
              child: Container(
                color: AppColors.transparent,
              ),
            ),
          ),

          // Minimize window button
          _TitleBarButton(
            icon: AppIcons.minimize,
            tooltip: 'Minimize',
            onPressed: _handleMinimize,
            hoverColor: AppColors.surfaceElevated,
          ),

          // Close window button (subtle red-tinted hover)
          _TitleBarButton(
            icon: AppIcons.close,
            tooltip: 'Close',
            onPressed: _handleClose,
            hoverColor: AppColors.error.withValues(alpha: 0.15),
            hoverIconColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  const _TitleBarButton({
    required this.icon,
    required this.onPressed,
    required this.hoverColor,
    this.hoverIconColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color hoverColor;
  final Color? hoverIconColor;
  final String? tooltip;

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = _isHovered && widget.hoverIconColor != null
        ? widget.hoverIconColor!
        : AppColors.textSecondary;

    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: AppDimensions.titleBarButtonWidth,
          height: AppDimensions.titleBarHeight,
          color: _isHovered ? widget.hoverColor : AppColors.transparent,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: AppDimensions.iconSizeSmall,
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
