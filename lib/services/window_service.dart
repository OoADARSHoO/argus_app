import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import '../core/constants/app_dimensions.dart';
import '../models/appearance_settings.dart';
import 'overlay_log.dart';

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

  /// Current settings-window size for the active UI scale.
  ///
  /// The overlay exit path restores THIS size, not the base 960x640, or every
  /// break would silently undo the user's UI scale.
  Size _settingsWindowSize = AppDimensions.windowSize;

  /// True once we have asked window_manager for fullscreen. The exit path
  /// must only undo fullscreen if this is set: window_manager's native
  /// restore path runs even when the window was never fullscreen, and it
  /// would resize the window back to a stale saved frame.
  bool _enteredFullScreen = false;

  /// True if fullscreen could not be confirmed and we fell back to
  /// maximizing the window instead.
  bool _usedMaximizeFallback = false;

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

  /// Becomes true when the window is actually fullscreen (or the enter
  /// timeout elapsed and the fallback ran). The break UI listens to this so
  /// it never lays itself out in a small settings-sized window that is still
  /// entering fullscreen.
  final ValueNotifier<bool> overlayReady = ValueNotifier<bool>(false);

  // Native window changes are not instant. These delays give Windows time to
  // apply each change before the next step reads the state back.
  static const Duration _settleDelay = Duration(milliseconds: 50);
  static const Duration _enterPollInterval = Duration(milliseconds: 100);
  static const Duration _enterPollTimeout = Duration(milliseconds: 1500);
  static const Duration _exitSettleDelay = Duration(milliseconds: 100);
  static const Duration _exitFrameTimeout = Duration(milliseconds: 300);
  static const Duration _exitSafetyDelay = Duration(seconds: 3);

  /// A fullscreen window is at least this much larger (by area) than the
  /// saved settings window. This is how we verify the real native size
  /// instead of trusting window_manager's cached isFullScreen() flag.
  static const double _fullScreenAreaGrowth = 1.05;

  /// Allowed pixel difference when checking that the saved bounds were
  /// restored. DPI rounding can shift a window by a pixel.
  static const double _boundsTolerance = 2.0;

  /// Initializes the main settings window, centered and frameless.
  ///
  /// [uiScale] is applied BEFORE the window is first shown, so the saved scale
  /// is visible from the first frame (no flash of the base 960x640 window).
  ///
  /// If [startHidden] is true (e.g. launched via `--autostart`), the window
  /// starts hidden in the tray instead of showing and focusing.
  ///
  /// Also enables prevent-close so that clicking X or pressing Alt+F4 does
  /// not quit the app. Instead, [onWindowClose] hides the window to the tray
  /// and the app keeps running (timer keeps ticking). Only "Exit Argus" quits.
  Future<void> initializeSettingsWindow({
    bool startHidden = false,
    int? uiScale,
    required Color backgroundColor,
  }) async {
    await windowManager.ensureInitialized();

    final windowOptions = WindowOptions(
      size: AppDimensions.windowSize,
      minimumSize: AppDimensions.windowSize,
      maximumSize: AppDimensions.windowSize,
      center: true,
      backgroundColor: backgroundColor,
      skipTaskbar: false,
      title: 'Argus',
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false);
      // Apply the saved UI scale before the first show, so the user never
      // sees the base-size window at the wrong size.
      await applyUiScale(uiScale ?? AppearanceSettings.defaults.uiScale);
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

  /// Updates the native window background brush.
  ///
  /// The brush can be visible for a frame before Flutter paints (startup and
  /// native resizes), so it must follow the active theme instead of keeping
  /// the dark startup color forever.
  Future<void> applyBackgroundColor(Color color) async {
    try {
      await windowManager.setBackgroundColor(color);
    } catch (e) {
      OverlayLog.write('BACKGROUND color FAILED: $e');
    }
  }

  /// Applies a UI scale [percent]: sizes the settings window and recenters it
  /// on the monitor it is currently on.
  ///
  /// The settings layout is always built at 960x640 and scaled to fill the
  /// window (see app.dart), so the window itself must be 960x640 * scale.
  ///
  /// If the scaled window would not fit the monitor's work area (for example
  /// 125% on a small laptop), the largest allowed scale that does fit is used
  /// for the window. The saved setting is left untouched, so the user's choice
  /// comes back on a larger screen.
  Future<void> applyUiScale(int percent) async {
    // Changing settings is impossible while the fullscreen break overlay is
    // up, and resizing then would fight the overlay. Apply on the next change.
    if (_isInOverlayMode) {
      OverlayLog.write('UI SCALE $percent% skipped: in overlay mode');
      return;
    }

    final monitor = await _currentMonitor();
    final effectivePercent = _largestFittingScale(percent, monitor);
    final size = AppDimensions.scaledWindowSize(effectivePercent);
    _settingsWindowSize = size;

    OverlayLog.write(
      'UI SCALE requested=$percent% effective=$effectivePercent% '
      'size=${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}',
    );

    try {
      // Min and max are set FIRST so the fixed-size window accepts the new
      // size, then setSize actually changes it.
      await windowManager.setMinimumSize(size);
      await windowManager.setMaximumSize(size);
      await windowManager.setSize(size);
      await _centerOnMonitor(monitor, size);
    } catch (e, s) {
      OverlayLog.write('UI SCALE apply FAILED: $e\n$s');
    }
  }

  /// The display that currently contains the settings window, or the primary
  /// display if that cannot be determined.
  Future<Display?> _currentMonitor() async {
    try {
      final displays = await screenRetriever.getAllDisplays();
      if (displays.isEmpty) return null;
      final bounds = await windowManager.getBounds();
      // Try the center first, then the top-left: a window can straddle two
      // monitors, and the center is the better guess for where it "lives".
      return _displayAt(displays, bounds.center) ??
          _displayAt(displays, bounds.topLeft) ??
          await screenRetriever.getPrimaryDisplay();
    } catch (e) {
      OverlayLog.write('UI SCALE monitor read FAILED: $e');
      return null;
    }
  }

  /// Returns the display whose work area contains [point], if any.
  Display? _displayAt(List<Display> displays, Offset point) {
    for (final display in displays) {
      if (_workAreaOf(display).contains(point)) return display;
    }
    return null;
  }

  /// Monitor work area (screen minus taskbar) in logical pixels.
  ///
  /// screen_retriever reports this in the same logical units as
  /// window_manager's sizes, so the numbers can be compared directly.
  Rect _workAreaOf(Display display) {
    final position = display.visiblePosition ?? Offset.zero;
    final size = display.visibleSize ?? display.size;
    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  /// Largest allowed scale no larger than [requestedPercent] whose window fits
  /// [monitor]'s work area.
  ///
  /// Falls back to the smallest allowed option when even that does not fit,
  /// and to [requestedPercent] when monitor data is unavailable (better to
  /// honour the setting than to guess).
  int _largestFittingScale(int requestedPercent, Display? monitor) {
    if (monitor == null) return requestedPercent;
    final workArea = _workAreaOf(monitor);
    var result = AppearanceSettings.uiScaleOptions.first;
    for (final percent in AppearanceSettings.uiScaleOptions) {
      if (percent > requestedPercent) continue;
      final size = AppDimensions.scaledWindowSize(percent);
      if (size.width <= workArea.width && size.height <= workArea.height) {
        result = percent;
      }
    }
    return result;
  }

  /// Centers [size] on [monitor]'s work area.
  Future<void> _centerOnMonitor(Display? monitor, Size size) async {
    try {
      if (monitor == null) {
        // Without display data, use the plugin's centering (it picks the
        // display under the cursor) rather than leaving the window off-center.
        await windowManager.center();
        return;
      }
      final workArea = _workAreaOf(monitor);
      await windowManager.setPosition(Offset(
        workArea.left + (workArea.width - size.width) / 2,
        workArea.top + (workArea.height - size.height) / 2,
      ));
    } catch (e, s) {
      OverlayLog.write('UI SCALE recenter FAILED: $e\n$s');
    }
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
      OverlayLog.write('OVERLAY step failed: $e\n$s');
    });
    return _overlayQueue;
  }

  /// Runs one window-manager call and logs the state before and after it.
  ///
  /// Every call is logged separately (instead of one big try/catch) because
  /// the whole point of this instrumentation is to find the exact call that
  /// fails or silently does nothing.
  Future<void> _loggedStep(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      OverlayLog.write('$label: ok');
    } catch (e, s) {
      OverlayLog.write('$label: ERROR $e\n$s');
    }
    await _logWindowState(label);
  }

  /// Formats a [Rect] with plain numbers.
  ///
  /// Release builds print `Instance of 'Rect'` for [Rect.toString], which
  /// makes the diagnostic log useless exactly when it is needed.
  String _formatBounds(Rect? rect) {
    if (rect == null) return 'null';
    return '${rect.left.toStringAsFixed(0)},${rect.top.toStringAsFixed(0)} '
        '${rect.width.toStringAsFixed(0)}x${rect.height.toStringAsFixed(0)}';
  }

  /// Reads the real window state back and writes it to the overlay log.
  ///
  /// Note: window_manager's `isFullScreen()` returns its own cached flag, not
  /// the native window state, so the bounds are the important part here.
  Future<void> _logWindowState(String label) async {
    try {
      final visible = await windowManager.isVisible();
      final fullScreen = await windowManager.isFullScreen();
      final onTop = await windowManager.isAlwaysOnTop();
      final bounds = await windowManager.getBounds();
      OverlayLog.write(
        '$label | visible=$visible fullScreen=$fullScreen '
        'onTop=$onTop bounds=${_formatBounds(bounds)}',
      );
    } catch (e) {
      OverlayLog.write('$label | state readback FAILED: $e');
    }
  }

  Future<void> _applyEnter() async {
    OverlayLog.write(
      'ENTER begin wanted=$_overlayWanted inOverlay=$_isInOverlayMode',
    );

    // The break was already skipped/ended while this step waited in the
    // queue, so going fullscreen now would only flash the screen.
    if (!_overlayWanted) {
      OverlayLog.write('ENTER skipped: break already ended');
      return;
    }
    if (_isInOverlayMode) {
      OverlayLog.write('ENTER skipped: already in overlay mode');
      return;
    }
    _isInOverlayMode = true;
    _enteredFullScreen = false;
    _usedMaximizeFallback = false;
    overlayReady.value = false;

    try {
      _overlayWasVisible = await windowManager.isVisible();
      _overlayBounds = await windowManager.getBounds();
      OverlayLog.write(
        'ENTER saved wasVisible=$_overlayWasVisible '
        'bounds=${_formatBounds(_overlayBounds)}',
      );
    } catch (e, s) {
      OverlayLog.write('ENTER saving window state FAILED: $e\n$s');
    }

    try {
      // Hide the settings frame before the native window changes shape.
      // Without this the old settings content is stretched over the screen
      // during the transition, and the reverse happens on the way out.
      await _loggedStep('ENTER setOpacity(0)', () async {
        await windowManager.setOpacity(0);
      });

      // window_manager 0.5.2 resizes the hidden HWND when setFullScreen is
      // called, and Windows may ignore that resize when the window is finally
      // shown (upstream issue #265). Show the (transparent) window first so
      // fullscreen is applied to a visible window every time.
      await _loggedStep('ENTER show()', () async {
        await windowManager.show();
      });
      await Future<void>.delayed(_settleDelay);

      // On Windows, setFullScreen silently fails if the window is
      // non-resizable or pinned to a fixed size, so lift those limits first.
      // [_restoreWindow] puts them back.
      await _loggedStep('ENTER setResizable(true)', () async {
        await windowManager.setResizable(true);
      });
      await _loggedStep('ENTER setMinimumSize(0,0)', () async {
        await windowManager.setMinimumSize(const Size(0, 0));
      });
      await _loggedStep('ENTER setMaximumSize(1e6)', () async {
        await windowManager.setMaximumSize(const Size(1e6, 1e6));
      });

      // The break may have been skipped while we waited above. Do not go
      // fullscreen for a break that no longer exists.
      if (!_overlayWanted) {
        OverlayLog.write('ENTER aborted: break ended before fullscreen');
        return;
      }

      await _loggedStep('ENTER setFullScreen(true)', () async {
        await windowManager.setFullScreen(true);
      });
      _enteredFullScreen = true;

      await _loggedStep('ENTER setAlwaysOnTop(true)', () async {
        await windowManager.setAlwaysOnTop(true);
      });
      await _loggedStep('ENTER focus()', () async {
        await windowManager.focus();
      });

      // window_manager reports the cached fullscreen flag, which can be true
      // while the window is still the settings size. Poll the real bounds
      // instead.
      final becameFullScreen = await _waitForFullScreen();

      // The break may have been skipped while we polled. Do not maximize or
      // reveal the overlay for a break that no longer exists.
      if (!_overlayWanted) {
        OverlayLog.write('ENTER aborted: break ended during fullscreen wait');
        return;
      }

      if (!becameFullScreen) {
        // Last resort: fill the work area. It is not true fullscreen, but the
        // break screen still covers the screen and stays on top.
        OverlayLog.write('ENTER fullscreen not confirmed; maximize fallback');
        await _loggedStep('ENTER maximize() fallback', () async {
          await windowManager.maximize();
        });
        _usedMaximizeFallback = true;
        await Future<void>.delayed(_exitSettleDelay);
        await _loggedStep('ENTER setAlwaysOnTop(true) fallback', () async {
          await windowManager.setAlwaysOnTop(true);
        });
        await _loggedStep('ENTER focus() fallback', () async {
          await windowManager.focus();
        });
      }

      overlayReady.value = true;
      OverlayLog.write('ENTER ready=true');
      // Let Flutter paint the break UI into the fullscreen surface while the
      // window is still transparent, then reveal the finished frame. Without
      // this wait the user can see the old settings frame for one vsync.
      await _waitForFrame();
      await _loggedStep('ENTER setOpacity(1)', () async {
        await windowManager.setOpacity(1);
      });
    } catch (e, s) {
      OverlayLog.write('ENTER failed: $e\n$s');
      // Even on failure the break UI must eventually appear; showing it in a
      // non-fullscreen window is better than leaving a transparent window.
      overlayReady.value = true;
    } finally {
      // Never leave the window invisible, even if an enter step failed.
      await _safeSetOpacity(1);
    }
  }

  /// Polls the real window bounds until the window is larger than the saved
  /// settings window. Returns false after the timeout.
  Future<bool> _waitForFullScreen() async {
    final saved = _overlayBounds;
    if (saved == null || saved.width <= 0 || saved.height <= 0) {
      // No baseline to compare against; give the native call time to land.
      await Future<void>.delayed(_enterPollInterval);
      return true;
    }

    final savedArea = saved.width * saved.height;
    final deadline = DateTime.now().add(_enterPollTimeout);
    while (DateTime.now().isBefore(deadline)) {
      if (!_overlayWanted) {
        OverlayLog.write('ENTER fullscreen wait aborted: break ended');
        return false;
      }
      try {
        final bounds = await windowManager.getBounds();
        final grew = bounds.width > saved.width || bounds.height > saved.height;
        final area = bounds.width * bounds.height;
        if (grew && area >= savedArea * _fullScreenAreaGrowth) {
          OverlayLog.write(
            'ENTER fullscreen confirmed bounds=${_formatBounds(bounds)} '
            'saved=${_formatBounds(saved)}',
          );
          return true;
        }
        OverlayLog.write(
          'ENTER waiting for fullscreen bounds=${_formatBounds(bounds)} '
          'saved=${_formatBounds(saved)}',
        );
      } catch (e) {
        OverlayLog.write('ENTER bounds readback failed: $e');
      }
      await Future<void>.delayed(_enterPollInterval);
    }
    OverlayLog.write('ENTER fullscreen timed out after $_enterPollTimeout');
    return false;
  }

  Future<void> _applyExit() async {
    OverlayLog.write(
      'EXIT begin wanted=$_overlayWanted inOverlay=$_isInOverlayMode '
      'wasVisible=$_overlayWasVisible bounds=${_formatBounds(_overlayBounds)}',
    );

    // A new break started while this step waited in the queue: stay put.
    if (_overlayWanted) {
      OverlayLog.write('EXIT skipped: a new break already started');
      return;
    }

    overlayReady.value = false;

    try {
      if (_isInOverlayMode) {
        await _restoreWindow();
        _isInOverlayMode = false;
        OverlayLog.write('EXIT restore finished');
      }
    } finally {
      _overlayBounds = null;
      _enteredFullScreen = false;
      _usedMaximizeFallback = false;
      // Always reset opacity, even if a restore step threw: a transparent
      // settings window would look like the app had disappeared.
      await _safeSetOpacity(1);
      _overlayExitSafetyTimer?.cancel();
      _overlayExitSafetyTimer = null;
    }
  }

  /// Undoes everything [_applyEnter] did. Every step has its own try/catch so
  /// one failure cannot stop the rest. Then it VERIFIES the result, because on
  /// Windows these calls can return without the window actually changing.
  Future<void> _restoreWindow() async {
    // Mask the whole transition. The Flutter tree may still be showing the
    // last overlay frame while the native window shrinks to the scaled
    // settings size; without opacity 0 the user sees the break UI stuck in a
    // small window.
    await _loggedStep('EXIT setOpacity(0)', () async {
      await windowManager.setOpacity(0);
    });

    for (var attempt = 0; attempt < 2; attempt++) {
      OverlayLog.write('EXIT restore attempt ${attempt + 1}');
      await _loggedStep('EXIT setAlwaysOnTop(false)', () async {
        await windowManager.setAlwaysOnTop(false);
      });

      // Only undo fullscreen if we actually entered it. Calling
      // setFullScreen(false) on a window that was never fullscreen makes
      // window_manager restore a stale saved frame and window style.
      if (_enteredFullScreen) {
        await _loggedStep('EXIT setFullScreen(false)', () async {
          await windowManager.setFullScreen(false);
        });
      } else if (_usedMaximizeFallback) {
        await _loggedStep('EXIT unmaximize()', () async {
          await windowManager.unmaximize();
        });
      } else if (await _safeIsFullScreen()) {
        // Defensive: a previous failed cycle may have left the cached flag on.
        await _loggedStep('EXIT setFullScreen(false) stuck flag', () async {
          await windowManager.setFullScreen(false);
        });
      }

      // Restore the exact pre-break geometry. Resizable must be on while the
      // bounds change, then the fixed limits for the current UI scale go back
      // on. Restoring the base 960x640 here would undo the user's scale after
      // every break.
      await _loggedStep('EXIT setResizable(true)', () async {
        await windowManager.setResizable(true);
      });
      if (_overlayBounds != null) {
        await _loggedStep('EXIT setBounds(saved)', () async {
          await windowManager.setBounds(_overlayBounds!);
        });
      }
      await _loggedStep('EXIT setMinimumSize(scaled)', () async {
        await windowManager.setMinimumSize(_settingsWindowSize);
      });
      await _loggedStep('EXIT setMaximumSize(scaled)', () async {
        await windowManager.setMaximumSize(_settingsWindowSize);
      });
      await _loggedStep('EXIT setResizable(false)', () async {
        await windowManager.setResizable(false);
      });

      // Verify the real geometry, not just the cached flags, and go around
      // once more if the window is still the wrong size.
      final restored = await _verifyRestored();
      if (restored) break;
      OverlayLog.write('EXIT still not restored, retrying');
    }

    // Let the native resize settle before deciding whether the window should
    // be visible. This also gives the timer's phase change time to rebuild
    // the Flutter tree back to the settings shell.
    await Future<void>.delayed(_exitSettleDelay);

    // Only re-show the window if the user had it open before the break.
    // Otherwise it goes back into the tray.
    if (_overlayWasVisible) {
      await _loggedStep('EXIT show()', () async {
        await windowManager.show();
      });
      await _loggedStep('EXIT focus()', () async {
        await windowManager.focus();
      });
    } else {
      await _loggedStep('EXIT hide()', () async {
        await windowManager.hide();
      });
    }

    // Make sure Flutter has painted the settings screen (or the hidden
    // window) before it becomes visible again. Without this wait the user
    // can see the old overlay frame at the restored settings size.
    await _waitForFrame();
  }

  /// Verifies the window is no longer on top / fullscreen and that its bounds
  /// match the saved pre-break bounds.
  Future<bool> _verifyRestored() async {
    try {
      final onTop = await windowManager.isAlwaysOnTop();
      final fullScreen = await windowManager.isFullScreen();
      final bounds = await windowManager.getBounds();
      final saved = _overlayBounds;
      final boundsOk = saved == null ||
          ((bounds.left - saved.left).abs() <= _boundsTolerance &&
              (bounds.top - saved.top).abs() <= _boundsTolerance &&
              (bounds.width - saved.width).abs() <= _boundsTolerance &&
              (bounds.height - saved.height).abs() <= _boundsTolerance);
      OverlayLog.write(
        'EXIT verify onTop=$onTop fullScreen=$fullScreen '
        'bounds=${_formatBounds(bounds)} saved=${_formatBounds(saved)} '
        'boundsOk=$boundsOk',
      );
      return !onTop && !fullScreen && boundsOk;
    } catch (e) {
      OverlayLog.write('EXIT verify FAILED: $e');
      return false;
    }
  }

  /// Waits for the next Flutter frame, but never longer than
  /// [_exitFrameTimeout] so a stuck engine cannot block the restore.
  Future<void> _waitForFrame() async {
    try {
      await SchedulerBinding.instance.endOfFrame.timeout(_exitFrameTimeout);
      OverlayLog.write('EXIT next frame painted');
    } on TimeoutException {
      OverlayLog.write('EXIT next frame timed out');
    } catch (e) {
      OverlayLog.write('EXIT next frame failed: $e');
    }
  }

  Future<void> _safeSetOpacity(double opacity) async {
    try {
      await windowManager.setOpacity(opacity);
      OverlayLog.write('setOpacity($opacity): ok');
    } catch (e) {
      OverlayLog.write('setOpacity($opacity) FAILED: $e');
    }
  }

  Future<bool> _safeIsFullScreen() async {
    try {
      return await windowManager.isFullScreen();
    } catch (e) {
      OverlayLog.write('EXIT isFullScreen readback FAILED: $e');
      return false;
    }
  }

  void _armOverlayExitSafetyTimer() {
    _overlayExitSafetyTimer?.cancel();
    OverlayLog.write('EXIT safety net armed (${_exitSafetyDelay.inSeconds}s)');
    _overlayExitSafetyTimer = Timer(_exitSafetyDelay, () async {
      _overlayExitSafetyTimer = null;
      // A new break may have started in the meantime.
      if (_overlayWanted) {
        OverlayLog.write('EXIT safety net: ignored, new break started');
        return;
      }
      OverlayLog.write('EXIT safety net: forcing overlay exit');
      // Bypasses the queue on purpose: the queue may be stuck on a hung call.
      try {
        await _restoreWindow();
        _isInOverlayMode = false;
      } catch (e, s) {
        OverlayLog.write('EXIT safety net failed: $e\n$s');
      } finally {
        _overlayBounds = null;
        _enteredFullScreen = false;
        _usedMaximizeFallback = false;
        // The safety net's most important job: never leave the window
        // transparent or invisible forever.
        await _safeSetOpacity(1);
      }
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
