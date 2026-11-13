import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../services/break_timer_service.dart';
import '../services/settings_service.dart';
import '../services/window_service.dart';
import '../utils/time_format.dart';

/// Service managing the system tray icon and context menu.
///
/// Plain class (not a ChangeNotifier) created once in [main]. It owns the
/// [trayManager] instance, builds the native context menu, and handles tray
/// icon clicks.
///
/// The menu is rebuilt on every right-click (just before showing) so the
/// "Next break in mm:ss" label stays live without rebuilding every second
/// (which would cause flicker). The tooltip is updated about once per
/// minute via a periodic timer.
///
/// File path for the tray icon: assets/icons/tray_icon.ico
class TrayService with TrayListener {
  static const String _iconPath = 'assets/icons/tray_icon.ico';
  static const Duration _tooltipUpdateInterval = Duration(minutes: 1);

  final SettingsService settingsService;
  final BreakTimerService breakTimerService;
  final WindowService windowService;

  Timer? _tooltipTimer;

  TrayService({
    required this.settingsService,
    required this.breakTimerService,
    required this.windowService,
  });

  /// Initialize the tray icon, context menu, and listeners.
  Future<void> init() async {
    await trayManager.setIcon(_iconPath);
    await trayManager.setToolTip('Argus');
    await _buildMenu();
    trayManager.addListener(this);
    _startTooltipTimer();
  }

  //--------------------------------------------------------------------------
  // TrayListener implementation
  //--------------------------------------------------------------------------

  @override
  void onTrayIconMouseDown() {
    // Left click: show and focus the settings window.
    windowService.showAndFocus();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Right click: rebuild the menu with the current countdown, then pop it up.
    // Note: on Windows both onTrayIconMouseDown and onTrayIconRightMouseDown
    // fire for a right-click, so showAndFocus() is also called — this is
    // harmless and the menu still appears.
    _buildMenu();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    // No action needed on right-mouse-up.
  }

  @override
  void onTrayIconMouseUp() {
    // No action needed on left-mouse-up.
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    // Menu item clicks are handled via each item's [onClick] callback.
    // This override is required by [TrayListener] but not used directly.
  }

  //--------------------------------------------------------------------------
  // Context menu
  //--------------------------------------------------------------------------

  /// Build the native context menu with the current timer state and set it
  /// as the tray context menu.
  ///
  /// Menu order:
  ///   1. "Next break in mm:ss" (disabled, informational)
  ///      - While paused: "Paused until HH:mm"
  ///      - During a break: "Break ends in mm:ss"
  ///   2. separator
  ///   3. "Pause for 1 hour" / "Resume" while paused
  ///   4. "Settings"
  ///   5. separator
  ///   6. "Exit Argus"
  Future<void> _buildMenu() async {
    final phase = breakTimerService.phase;

    // First item: informational countdown (disabled).
    String firstLabel;
    if (phase == TimerPhase.paused) {
      final until = breakTimerService.pausedUntil;
      firstLabel = until != null
          ? 'Paused until ${_formatHm(until)}'
          : 'Paused';
    } else if (phase == TimerPhase.breakTime) {
      final remaining = breakTimerService.secondsLeftInBreak;
      firstLabel = 'Break ends in ${formatSeconds(remaining)}';
    } else {
      final remaining = breakTimerService.secondsUntilBreak;
      firstLabel = 'Next break in ${formatSeconds(remaining)}';
    }

    // Pause / Resume toggle.
    final pauseLabel = phase == TimerPhase.paused ? 'Resume' : 'Pause for 1 hour';

    final menu = Menu(items: [
      MenuItem(label: firstLabel, disabled: true),
      MenuItem.separator(),
      MenuItem(
        label: pauseLabel,
        onClick: (_) => _handlePauseResume(),
      ),
      MenuItem(
        label: 'Settings',
        onClick: (_) => _handleSettings(),
      ),
      MenuItem.separator(),
      MenuItem(
        label: 'Exit Argus',
        onClick: (_) => _handleExit(),
      ),
    ]);

    await trayManager.setContextMenu(menu);
  }

  /// Format a DateTime as HH:mm for the "Paused until" label.
  static String _formatHm(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  //--------------------------------------------------------------------------
  // Tray menu action handlers
  //--------------------------------------------------------------------------

  void _handleSettings() {
    // Fire-and-forget; showAndFocus is async but we don't need to await it
    // from a menu click handler.
    windowService.showAndFocus();
  }

  void _handlePauseResume() {
    final phase = breakTimerService.phase;
    if (phase == TimerPhase.paused) {
      breakTimerService.resume();
    } else {
      breakTimerService.pauseForOneHour();
    }
    // Rebuild the menu so the Pause/Resume label and countdown stay live.
    _buildMenu();
  }

  /// Clean shutdown: flush pending settings, dispose the break timer,
  /// destroy the tray icon, then destroy the window.
  void _handleExit() {
    // Fire-and-forget async shutdown. The callback is synchronous so we
    // can't await, but flush() writes quickly to disk.
    _shutdown();
  }

  Future<void> _shutdown() async {
    // Flush any pending debounced settings save so the last change isn't lost.
    await settingsService.flush();
    // Stop the break timer.
    breakTimerService.dispose();
    // Release the single instance file lock on clean exit.
    releaseSingleInstanceLock();
    // Remove the tray icon.
    await trayManager.destroy();
    // Quit the application.
    await windowManager.destroy();
  }

  /// Update the tray tooltip about once per minute so it reflects the
  /// current countdown without requiring a menu rebuild.
  void _startTooltipTimer() {
    _tooltipTimer = Timer.periodic(_tooltipUpdateInterval, (_) async {
      final phase = breakTimerService.phase;
      String tooltip;
      if (phase == TimerPhase.paused) {
        tooltip = 'Argus - Paused';
      } else if (phase == TimerPhase.breakTime) {
        final remaining = breakTimerService.secondsLeftInBreak;
        tooltip = 'Argus - Break ends in ${formatSeconds(remaining)}';
      } else {
        final remaining = breakTimerService.secondsUntilBreak;
        tooltip = 'Argus - Next break in ${formatSeconds(remaining)}';
      }
      await trayManager.setToolTip(tooltip);
    });
  }

  /// Called when the app shuts down. Cancels the tooltip timer.
  void dispose() {
    _tooltipTimer?.cancel();
  }

  /// Destroy the tray icon. Called when the app is shutting down to apply an
  /// update.
  Future<void> destroy() async {
    try {
      await trayManager.destroy();
    } catch (e) {
      debugPrint('Failed to destroy tray icon: $e');
    }
  }
}
