import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../services/settings_service.dart';
import '../../services/window_service.dart';
import '../../widgets/sidebar/sidebar_nav.dart';
import '../../widgets/titlebar/custom_title_bar.dart';
import 'about_page.dart';
import 'appearance_page.dart';
import 'break_page.dart';
import 'general_page.dart';
import 'support_page.dart';

/// Main Settings Window Shell for Argus.
/// Hosts the custom title bar, sidebar navigation, and current page content.
///
/// All settings are read from and written to [settingsService].
class SettingsShell extends StatefulWidget {
  const SettingsShell({
    super.key,
    required this.windowService,
    required this.settingsService,
  });

  final WindowService windowService;
  final SettingsService settingsService;

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell> {
  SettingsTab _selectedTab = SettingsTab.general;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Custom frameless Title Bar
              CustomTitleBar(
                onMinimize: () => widget.windowService.minimize(),
                onClose: () => widget.windowService.close(),
              ),

              // Main body area (Sidebar + Content)
              // crossAxisAlignment.stretch ensures the content container starts
              // right below the title bar with no extra vertical gap on any tab.
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sidebar navigation
                    SidebarNav(
                      selectedTab: _selectedTab,
                      accentColor: widget.settingsService.accentColor,
                      onTabSelected: (tab) {
                        setState(() => _selectedTab = tab);
                      },
                    ),

                    // Content page area
                    Expanded(
                      child: Container(
                        color: AppColors.background,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.windowPadding),
                          child: _buildCurrentPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage() {
    final service = widget.settingsService;
    switch (_selectedTab) {
      case SettingsTab.general:
        return GeneralPage(settings: service);
      case SettingsTab.breakTab:
        return BreakPage(settings: service);
      case SettingsTab.appearance:
        return AppearancePage(settings: service);
      case SettingsTab.support:
        return SupportPage(settings: service);
      case SettingsTab.about:
        return AboutPage(settings: service);
    }
  }
}
