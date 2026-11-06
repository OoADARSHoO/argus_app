import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../services/window_service.dart';
import '../../widgets/sidebar/sidebar_nav.dart';
import '../../widgets/titlebar/custom_title_bar.dart';
import 'about_page.dart';
import 'appearance_page.dart';
import 'break_page.dart';
import 'general_page.dart';
import 'support_page.dart';

/// Temporary in-memory state holder for settings values during Phase 3.
/// NOTE: This is temporary and will be replaced by real persistent models
/// and SettingsService in Phase 4.
class TempSettingsState extends ChangeNotifier {
  // General settings
  String _breakInterval = '20 minutes';
  String _breakDuration = '20 seconds';
  bool _skipOption = true;
  bool _startOnStartup = true;
  bool _showNotifications = true;
  bool _enableSounds = false;

  // Break settings
  String _breakMessage =
      'Time to rest your eyes. Look at something 20 feet away for 20 seconds.';
  String _breakBackground = 'Black Screen';
  Color _textColor = const Color(0xFFF5F5F5);
  String _fontSize = 'Large';
  bool _showProgressRing = true;

  // Appearance settings
  String _selectedTheme = 'Dark';
  Color _selectedAccentColor = AppColors.accentBlue;
  String _uiScale = '100% (Default)';

  // Getters
  String get breakInterval => _breakInterval;
  String get breakDuration => _breakDuration;
  bool get skipOption => _skipOption;
  bool get startOnStartup => _startOnStartup;
  bool get showNotifications => _showNotifications;
  bool get enableSounds => _enableSounds;

  String get breakMessage => _breakMessage;
  String get breakBackground => _breakBackground;
  Color get textColor => _textColor;
  String get fontSize => _fontSize;
  bool get showProgressRing => _showProgressRing;

  String get selectedTheme => _selectedTheme;
  Color get selectedAccentColor => _selectedAccentColor;
  String get uiScale => _uiScale;

  // Setters with notifyListeners()
  void setBreakInterval(String value) {
    if (_breakInterval != value) {
      _breakInterval = value;
      notifyListeners();
    }
  }

  void setBreakDuration(String value) {
    if (_breakDuration != value) {
      _breakDuration = value;
      notifyListeners();
    }
  }

  void setSkipOption(bool value) {
    if (_skipOption != value) {
      _skipOption = value;
      notifyListeners();
    }
  }

  void setStartOnStartup(bool value) {
    if (_startOnStartup != value) {
      _startOnStartup = value;
      notifyListeners();
    }
  }

  void setShowNotifications(bool value) {
    if (_showNotifications != value) {
      _showNotifications = value;
      notifyListeners();
    }
  }

  void setEnableSounds(bool value) {
    if (_enableSounds != value) {
      _enableSounds = value;
      notifyListeners();
    }
  }

  void setBreakMessage(String value) {
    if (_breakMessage != value) {
      _breakMessage = value;
      notifyListeners();
    }
  }

  void setBreakBackground(String value) {
    if (_breakBackground != value) {
      _breakBackground = value;
      notifyListeners();
    }
  }

  void setTextColor(Color value) {
    if (_textColor != value) {
      _textColor = value;
      notifyListeners();
    }
  }

  void setFontSize(String value) {
    if (_fontSize != value) {
      _fontSize = value;
      notifyListeners();
    }
  }

  void setShowProgressRing(bool value) {
    if (_showProgressRing != value) {
      _showProgressRing = value;
      notifyListeners();
    }
  }

  void setSelectedTheme(String value) {
    if (_selectedTheme != value) {
      _selectedTheme = value;
      notifyListeners();
    }
  }

  void setSelectedAccentColor(Color value) {
    if (_selectedAccentColor != value) {
      _selectedAccentColor = value;
      notifyListeners();
    }
  }

  void setUiScale(String value) {
    if (_uiScale != value) {
      _uiScale = value;
      notifyListeners();
    }
  }
}

/// Main Settings Window Shell for Argus.
/// Hosts the custom title bar, sidebar navigation, and current page content.
class SettingsShell extends StatefulWidget {
  const SettingsShell({
    super.key,
    this.windowService = const WindowService(),
  });

  final WindowService windowService;

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell> {
  SettingsTab _selectedTab = SettingsTab.general;
  late final TempSettingsState _settings;

  @override
  void initState() {
    super.initState();
    _settings = TempSettingsState();
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  Widget _buildCurrentPage() {
    switch (_selectedTab) {
      case SettingsTab.general:
        return GeneralPage(settings: _settings);
      case SettingsTab.breakTab:
        return BreakPage(settings: _settings);
      case SettingsTab.appearance:
        return AppearancePage(settings: _settings);
      case SettingsTab.support:
        return SupportPage(settings: _settings);
      case SettingsTab.about:
        return AboutPage(settings: _settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
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
              Expanded(
                child: Row(
                  children: [
                    // Sidebar navigation
                    SidebarNav(
                      selectedTab: _selectedTab,
                      accentColor: _settings.selectedAccentColor,
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
}
