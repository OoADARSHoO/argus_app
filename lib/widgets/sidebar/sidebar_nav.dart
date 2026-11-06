import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../icons/app_icons.dart';
import 'sidebar_nav_item.dart';

/// Available settings tabs in the sidebar navigation.
enum SettingsTab {
  general,
  breakTab,
  appearance,
  support,
  about,
}

/// Navigation sidebar for the Argus Settings window.
/// 180px wide with a surface background and 1px divider on the right edge.
class SidebarNav extends StatelessWidget {
  const SidebarNav({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.accentColor,
  });

  final SettingsTab selectedTab;
  final ValueChanged<SettingsTab> onTabSelected;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = (AppDimensions.sidebarWidth - AppDimensions.sidebarItemWidth) / 2;

    return Container(
      width: AppDimensions.sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.divider,
            width: AppDimensions.borderWidth,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.s16,
      ),
      child: Column(
        children: [
          SidebarNavItem(
            label: 'General',
            icon: AppIcons.home,
            isSelected: selectedTab == SettingsTab.general,
            accentColor: accentColor,
            onTap: () => onTabSelected(SettingsTab.general),
          ),
          const SizedBox(height: AppSpacing.s8),
          SidebarNavItem(
            label: 'Break',
            icon: AppIcons.clock,
            isSelected: selectedTab == SettingsTab.breakTab,
            accentColor: accentColor,
            onTap: () => onTabSelected(SettingsTab.breakTab),
          ),
          const SizedBox(height: AppSpacing.s8),
          SidebarNavItem(
            label: 'Appearance',
            icon: AppIcons.pencil,
            isSelected: selectedTab == SettingsTab.appearance,
            accentColor: accentColor,
            onTap: () => onTabSelected(SettingsTab.appearance),
          ),
          const SizedBox(height: AppSpacing.s8),
          SidebarNavItem(
            label: 'Support',
            icon: AppIcons.heart,
            isSelected: selectedTab == SettingsTab.support,
            accentColor: accentColor,
            onTap: () => onTabSelected(SettingsTab.support),
          ),
          const SizedBox(height: AppSpacing.s8),
          SidebarNavItem(
            label: 'About',
            icon: AppIcons.info,
            isSelected: selectedTab == SettingsTab.about,
            accentColor: accentColor,
            onTap: () => onTabSelected(SettingsTab.about),
          ),
        ],
      ),
    );
  }
}
