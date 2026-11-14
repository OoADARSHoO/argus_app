import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  /// What the break timer currently WANTS (true during a break). Enter/exit
  /// calls update this immediately, so a queued action that has become stale
  /// (e.g. the break was skipped while the window was still going fullscreen)
  /// can detect it and do nothing.
  bool _overlayWanted = false;

  /// Overlay transitions run one at a time through this chain. Without it,
  /// a fast skip makes [exitOverlayMode] run in the middle of
  /// [enterOverlayMode]: the two sets of platform calls interleave and the
  /// window can end up fullscreen/always-on-top after "closing".
  Future<void> _overlayQueue = Future<void>.value();

  /// Safety-net timer. Armed when an exit is requested and cancelled only once
  /// the exit has finished and been verified. If it fires, the normal path
  /// hung or failed, so we run the restore steps again, bypassing the queue.
  Timer? _overlayExitSafetyTimer;

  /// Initializes the main settings window at 960x640, centered, frameless.
  ///
  /// If [startHidden] is true (e.g. launched via `--autostart`), the window
  /// starts hidden in the tray instead of showing and focusing.
  ///
  /// Also enables prevent-close so that clicking X or pressing Alt+F4 does
  /// not quit the app. Instead, [onWindowClose] hides the window to the tray
  /// and the app keeps running (timer keeps ticking). Only "Exit Argus" quits.
  Future<void> initializeSettingsWindow({bool startHidden = false}) async {
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
      if (!startHidden) {
        await windowManager.show();
        await windowManager.focus();
      } else {
        await windowManager.hide();
      }
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
  /// Saves the current window state (visibility, size, position) so it can be
  /// restored by [exitOverlayMode]. Safe to call multiple times.
  Future<void> enterOverlayMode() {
    _overlayWanted = true;
    // A new break is starting, so any pending "force exit" is obsolete.
    _overlayExitSafetyTimer?.cancel();
    _overlayExitSafetyTimer = null;
    return _enqueueOverlayStep(_applyEnter);
  }

  /// Restores the window to its pre-overlay state (size, position,
  /// always-on-top, visibility). If the window was hidden in the tray before
  /// the break, it is hidden again. Safe to call multiple times.
  Future<void> exitOverlayMode() {
    _overlayWanted = false;
    _armOverlayExitSafetyTimer();
    return _enqueueOverlayStep(_applyExit);
  }

  /// Runs [step] after every previously requested overlay step has finished.
  Future<void> _enqueueOverlayStep(Future<void> Function() step) {
    _overlayQueue = _overlayQueue.then((_) => step()).catchError((Object e, StackTrace s) {
      // Never let one failed step break the chain for later steps.
      debugPrint('DEBUG OVERLAY: step failed: $e\n$s');
    });
    return _overlayQueue;
  }

  Future<void> _applyEnter() async {
    // The break was already skipped/ended while this step waited in the
    // queue, so going fullscreen now would only flash the screen.
    if (!_overlayWanted) return;
    if (_isInOverlayMode) return;
    _isInOverlayMode = true;

    try {
      _overlayWasVisible = await windowManager.isVisible();
      _overlayBounds = await windowManager.getBounds();

      // On Windows, setFullScreen silently fails if the window is
      // non-resizable or pinned to a fixed size, so lift those limits first.
      // [_restoreWindow] puts them back.
      await windowManager.setResizable(true);
      await windowManager.setMinimumSize(const Size(0, 0));
      await windowManager.setMaximumSize(const Size(1e6, 1e6));

      await windowManager.setFullScreen(true);
      await windowManager.setAlwaysOnTop(true);
      await windowManager.show();
      await windowManager.focus();
    } catch (e, s) {
      // _isInOverlayMode stays true so the exit step still cleans up.
      debugPrint('DEBUG OVERLAY ERROR in enterOverlayMode: $e\n$s');
    }
  }

  Future<void> _applyExit() async {
    // A new break started while this step waited in the queue: stay put.
    if (_overlayWanted) return;

    if (_isInOverlayMode) {
      await _restoreWindow();
      _isInOverlayMode = false;
    }
    _overlayBounds = null;

    // Finished: the safety net is no longer needed.
    _overlayExitSafetyTimer?.cancel();
    _overlayExitSafetyTimer = null;
  }

  /// Undoes everything [_applyEnter] did. Every step has its own try/catch so
  /// one failure cannot stop the rest. Then it VERIFIES the result, because on
  /// Windows these calls can return without the window actually changing.
  Future<void> _restoreWindow() async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await windowManager.setAlwaysOnTop(false);
      } catch (e) {
        debugPrint('DEBUG OVERLAY: setAlwaysOnTop(false) failed: $e');
      }
      try {
        await windowManager.setFullScreen(false);
      } catch (e) {
        debugPrint('DEBUG OVERLAY: setFullScreen(false) failed: $e');
      }

      // Back to the fixed 960x640 settings window.
      try {
        await windowManager.setResizable(false);
        await windowManager.setMinimumSize(AppDimensions.windowSize);
        await windowManager.setMaximumSize(AppDimensions.windowSize);
      } catch (e) {
        debugPrint('DEBUG OVERLAY: restoring size limits failed: $e');
      }
      if (_overlayBounds != null) {
        try {
          await windowManager.setBounds(_overlayBounds!);
        } catch (e) {
          debugPrint('DEBUG OVERLAY: setBounds failed: $e');
        }
      }

      // Verify, and go around once more if the window is still stuck.
      var stillStuck = false;
      try {
        stillStuck = await windowManager.isFullScreen() ||
            await windowManager.isAlwaysOnTop();
      } catch (e) {
        debugPrint('DEBUG OVERLAY: verify failed: $e');
      }
      if (!stillStuck) break;
      debugPrint('DEBUG OVERLAY: window still fullscreen/on top, retrying');
    }

    // Only re-show the window if the user had it open before the break.
    // Otherwise it goes back into the tray.
    try {
      if (_overlayWasVisible) {
        await windowManager.show();
        await windowManager.focus();
      } else {
        await windowManager.hide();
      }
    } catch (e) {
      debugPrint('DEBUG OVERLAY: show/hide failed: $e');
    }

    // Flutter can keep painting the last (overlay) frame after a native
    // resize, which looks like a window that "won't close". Force fresh
    // frames now and again once the resize has settled.
    SchedulerBinding.instance.scheduleForcedFrame();
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      SchedulerBinding.instance.scheduleForcedFrame();
    });
  }

  void _armOverlayExitSafetyTimer() {
    _overlayExitSafetyTimer?.cancel();
    _overlayExitSafetyTimer = Timer(const Duration(seconds: 3), () async {
      _overlayExitSafetyTimer = null;
      // A new break may have started in the meantime.
      if (_overlayWanted) return;
      debugPrint('DEBUG OVERLAY: Safety net: forcing overlay exit');
      // Bypasses the queue on purpose: the queue may be stuck on a hung call.
      await _restoreWindow();
      _isInOverlayMode = false;
      _overlayBounds = null;
    });
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