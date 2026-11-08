import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../services/break_timer_service.dart';
import '../../services/settings_service.dart';
import '../../services/tray_service.dart';
import '../../services/window_service.dart';
import '../../utils/time_format.dart';
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
/// The [breakTimerService] drives the 20-20-20 cycle and powers the
/// temporary debug panel below.
/// The [trayService] handles hide-to-tray and tray menu actions.
class SettingsShell extends StatefulWidget {
  const SettingsShell({
    super.key,
    required this.windowService,
    required this.settingsService,
    required this.breakTimerService,
    required this.trayService,
  });

  final WindowService windowService;
  final SettingsService settingsService;
  final BreakTimerService breakTimerService;
  final TrayService trayService;

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell> {
  SettingsTab _selectedTab = SettingsTab.general;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.settingsService,
        widget.breakTimerService,
      ]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Custom frameless Title Bar.
              // Close hides to tray instead of quitting (prevent-close is on).
              CustomTitleBar(
                onMinimize: () => widget.windowService.minimize(),
                onClose: _hideToTray,
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

              // TEMPORARY DEBUG PANEL — remove in Phase 7
              // Shows the break timer state so it can be observed before the
              // overlay exists. Only visible in debug mode.
              if (kDebugMode) _DebugTimerPanel(
                timer: widget.breakTimerService,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Hide the settings window to the tray instead of quitting.
  /// Flushes pending settings first so the last change is persisted.
  Future<void> _hideToTray() async {
    await widget.settingsService.flush();
    await widget.windowService.hideToTray();
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

/// Temporary debug panel showing live break timer state.
///
/// TEMPORARY — remove in Phase 7 when the break overlay replaces this.
class _DebugTimerPanel extends StatelessWidget {
  const _DebugTimerPanel({
    required this.timer,
  });

  final BreakTimerService timer;

  @override
  Widget build(BuildContext context) {
    final phase = timer.phase;

    // Paused: show "Paused until HH:mm" instead of a countdown.
    String countdownText;
    if (phase == TimerPhase.paused) {
      final until = timer.pausedUntil;
      countdownText = until != null
          ? 'Paused until ${_formatHm(until)}'
          : 'Paused';
    } else {
      final remaining = phase == TimerPhase.breakTime
          ? timer.secondsLeftInBreak
          : timer.secondsUntilBreak;
      final label = phase == TimerPhase.breakTime
          ? 'Break ends in'
          : 'Next break in';
      countdownText = '$label ${formatSeconds(remaining)}';
    }

    return Container(
      height: AppDimensions.titleBarHeight * 2,
      color: AppColors.surfaceElevated,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Row(
        children: [
          // Phase indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: _phaseColor(phase),
              borderRadius: AppRadius.badgeRadius,
            ),
            child: Text(
              _phaseLabel(phase),
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),

          // Countdown / pause text
          Text(
            countdownText,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          if (timer.preBreakWarning) ...[
            const SizedBox(width: AppSpacing.s16),
            Text(
              'WARNING',
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const Spacer(),

          // Debug buttons
          _DebugButton(
            label: 'Break now',
            onPressed: timer.startBreakNow,
          ),
          const SizedBox(width: AppSpacing.s8),
          _DebugButton(
            label: 'Skip',
            onPressed: timer.skipBreak,
            enabled: timer.phase == TimerPhase.breakTime,
          ),
          const SizedBox(width: AppSpacing.s8),
          _DebugButton(
            label: 'Pause',
            onPressed: timer.pauseForOneHour,
            enabled: timer.phase == TimerPhase.working,
          ),
          const SizedBox(width: AppSpacing.s8),
          _DebugButton(
            label: 'Resume',
            onPressed: timer.resume,
            enabled: timer.phase == TimerPhase.paused,
          ),
        ],
      ),
    );
  }

  static String _formatHm(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _phaseColor(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.working:
        return AppColors.primary.withValues(alpha: 0.15);
      case TimerPhase.breakTime:
        return AppColors.warning.withValues(alpha: 0.15);
      case TimerPhase.paused:
        return AppColors.textTertiary.withValues(alpha: 0.15);
    }
  }

  String _phaseLabel(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.working:
        return 'WORKING';
      case TimerPhase.breakTime:
        return 'BREAK';
      case TimerPhase.paused:
        return 'PAUSED';
    }
  }
}

/// A small outlined debug button.
class _DebugButton extends StatelessWidget {
  const _DebugButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: enabled ? AppColors.textPrimary : AppColors.textDisabled,
        side: BorderSide(
          color: enabled ? AppColors.border : AppColors.textDisabled,
          width: AppDimensions.borderWidth,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
        ),
      ),
    );
  }
}
