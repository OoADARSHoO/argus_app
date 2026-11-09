import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Service managing desktop window properties, frameless title bar,
/// sizing, and window actions using [windowManager].
class WindowService {
  /// Optional callback invoked when the user attempts to close the window
  /// (X button or Alt+F4). Used to flush pending settings before hiding.
  final void Function()? onCloseRequested;

  WindowService({this.onCloseRequested});

  // Cached state used to restore the window after exiting overlay mode.
  bool _overlayWasVisible = false;
  Rect? _overlayBounds;
  bool _isInOverlayMode = false;

  /// Initializes the main settings window at 960x640, centered, frameless.
  ///
  /// Also enables prevent-close so that clicking X or pressing Alt+F4 does
  /// not quit the app. Instead, [onWindowClose] hides the window to the tray
  /// and the app keeps running (timer keeps ticking). Only "Exit Argus" quits.
  Future<void> initializeSettingsWindow() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: AppDimensions.windowSize,
      minimumSize: AppDimensions.windowSize,
      maximumSize: AppDimensions.windowSize,
      center: true,
      backgroundColor: AppColors.background,
      skipTaskbar: false,
      title: 'Argus',
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    });

    // Prevent the window from actually closing when the user clicks X or
    // presses Alt+F4. Instead, we hide it to the tray and keep the app
    // running. Only "Exit Argus" quits.
    await windowManager.setPreventClose(true);
    windowManager.addListener(_WindowListener(onCloseRequested: onCloseRequested));
  }

  /// Minimizes the application window.
  Future<void> minimize() async {
    await windowManager.minimize();
  }

  /// Closes the application window (quits the app).
  Future<void> close() async {
    await windowManager.close();
  }

  /// Hide the window to the tray without quitting. Called when the user
  /// clicks X or Alt+F4. The app keeps running and the timer keeps ticking.
  Future<void> hideToTray() async {
    await windowManager.hide();
  }

  /// Show and focus the settings window. Restores if minimized.
  Future<void> showAndFocus() async {
    final isVisible = await windowManager.isVisible();
    if (!isVisible) {
      await windowManager.show();
    }
    // Restore from maximized state if needed so the window is usable.
    final isMaximized = await windowManager.isMaximized();
    if (isMaximized) {
      await windowManager.restore();
    }
    await windowManager.focus();
  }

  /// Switches the window to fullscreen overlay mode for a break.
  ///
  /// Saves the current window state (visibility, size, position,
  /// always-on-top) so it can be restored by [exitOverlayMode].
  /// Safe to call multiple times — returns early if already in overlay mode.
  Future<void> enterOverlayMode() async {
    if (_isInOverlayMode) return;

    _isInOverlayMode = true;

    // Remember the current state so we can restore it later.
    _overlayWasVisible = await windowManager.isVisible();
    _overlayBounds = await windowManager.getBounds();

    // Make the window resizable and remove the min/max size constraints
    // BEFORE calling setFullScreen. On Windows, setFullScreen silently fails
    // if the window is non-resizable or pinned to a fixed min/max size.
    // We restore these constraints in [exitOverlayMode].
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(const Size(0, 0));
    await windowManager.setMaximumSize(const Size(1e6, 1e6));

    // Go frameless, fullscreen, always-on-top on the current monitor.
    await windowManager.setFullScreen(true);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
    await windowManager.focus();
  }

  /// Restores the window to its pre-overlay state.
  ///
  /// Restores size, position, and always-on-top. If the window was hidden
  /// in the tray before the break, hides it again instead of showing.
  /// Safe to call multiple times — returns early if not in overlay mode.
  Future<void> exitOverlayMode() async {
    if (!_isInOverlayMode) return;

    _isInOverlayMode = false;

    // Leave fullscreen and always-on-top.
    await windowManager.setFullScreen(false);
    await windowManager.setAlwaysOnTop(false);

    // Restore non-resizable and fixed size constraints so it goes back to
    // a fixed 960x640 settings window.
    await windowManager.setResizable(false);
    await windowManager.setMinimumSize(AppDimensions.windowSize);
    await windowManager.setMaximumSize(AppDimensions.windowSize);

    // Restore the saved size and position.
    if (_overlayBounds != null) {
      await windowManager.setBounds(_overlayBounds!);
    }

    // If the window was hidden in the tray before the break, hide it again.
    // Otherwise show and focus it.
    if (_overlayWasVisible) {
      await windowManager.show();
      await windowManager.focus();
    } else {
      await windowManager.hide();
    }
  }
}

/// Window listener that intercepts close attempts and hides the window
/// instead of quitting.
class _WindowListener extends WindowListener {
  final void Function()? onCloseRequested;

  _WindowListener({this.onCloseRequested});

  @override
  Future<void> onWindowClose() async {
    // Notify the shell (e.g. to flush pending settings) before hiding.
    onCloseRequested?.call();
    // Hide instead of closing. The app stays in the tray and keeps running.
    await windowManager.hide();
  }
}
