import 'dart:io';
import 'package:flutter/widgets.dart';
import 'app.dart';
import 'services/break_timer_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/startup_service.dart';
import 'services/tray_service.dart';
import 'services/window_service.dart';

/// Exclusive file lock reference kept for the lifetime of the process.
///
/// We use a file lock ([RandomAccessFile.lock] with [FileLock.exclusive])
/// on `%APPDATA%\Argus\app.lock`. A file lock is ideal for single-instance
/// enforcement because the Windows kernel automatically releases the lock if
/// the process terminates or crashes unexpectedly, preventing stale locks.
RandomAccessFile? _appLockFile;

/// Acquires an exclusive lock on `%APPDATA%\Argus\app.lock`.
/// Returns true if the lock was acquired, false if another instance holds it.
Future<bool> _acquireSingleInstanceLock() async {
  try {
    final appData = Platform.environment['APPDATA'];
    if (appData == null || appData.isEmpty) {
      // If APPDATA is unavailable, allow running.
      return true;
    }
    final dir = Directory('$appData\\Argus');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final lockFile = File('${dir.path}\\app.lock');
    final raf = await lockFile.open(mode: FileMode.write);
    await raf.lock(FileLock.exclusive);
    _appLockFile = raf;
    return true;
  } catch (e) {
    debugPrint('Another instance of Argus is already running: $e');
    try {
      await _appLockFile?.close();
    } catch (_) {}
    _appLockFile = null;
    return false;
  }
}

/// Releases the exclusive file lock on clean application exit.
void releaseSingleInstanceLock() {
  try {
    _appLockFile?.unlockSync();
    _appLockFile?.closeSync();
  } catch (e) {
    debugPrint('Error releasing single instance lock: $e');
  } finally {
    _appLockFile = null;
  }
}

/// Entry point for Argus desktop application.
/// Initializes the single instance lock, window, settings, break timer,
/// startup service, notification and tray services, then runs the app.
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Single Instance Check:
  // Try to acquire an exclusive lock on %APPDATA%\Argus\app.lock.
  // If another instance is already running, exit immediately without creating
  // a tray icon or window.
  final lockAcquired = await _acquireSingleInstanceLock();
  if (!lockAcquired) {
    exit(0);
  }

  // Check if launched via Windows startup (--autostart)
  final isAutostart = args.contains(StartupService.autostartArg);

  final settingsService = SettingsService();
  await settingsService.load();

  // 2. Startup Service:
  // Manages launch at Windows startup and syncs registry state with settings.
  final startupService = StartupService();
  startupService.setup();
  await startupService.syncWithSetting(settingsService.settings.startOnStartup);

  // Keep registry in sync whenever the user toggles "Start on Windows Startup".
  bool lastStartupSetting = settingsService.settings.startOnStartup;
  settingsService.addListener(() {
    final currentStartupSetting = settingsService.settings.startOnStartup;
    if (currentStartupSetting != lastStartupSetting) {
      lastStartupSetting = currentStartupSetting;
      startupService.syncWithSetting(currentStartupSetting);
    }
  });

  // WindowService needs the onCloseRequested callback to flush pending
  // settings when the user tries to close the window (X or Alt+F4).
  final windowService = WindowService(
    onCloseRequested: () => settingsService.flush(),
  );

  // If started via --autostart, start HIDDEN in the tray (no settings window).
  // A normal launch shows and focuses the settings window.
  await windowService.initializeSettingsWindow(startHidden: isAutostart);

  // Create the break timer service once and start it.
  final breakTimerService = BreakTimerService(
    settingsService: settingsService,
  );
  breakTimerService.start();

  // Create the notification service once and set it up at startup.
  final notificationService = NotificationService();
  await notificationService.setup();

  // Listen to timer phase transitions and switch window overlay mode.
  // When the timer enters breakTime, the window goes fullscreen always-on-top
  // and shows the break overlay. When it leaves breakTime, the window is
  // restored to its pre-break state.
  TimerPhase lastTimerPhase = TimerPhase.working;
  bool lastPreBreakWarning = false;
  breakTimerService.addListener(() {
    final currentPhase = breakTimerService.phase;
    if (lastTimerPhase != currentPhase) {
      lastTimerPhase = currentPhase;
      if (currentPhase == TimerPhase.breakTime) {
        windowService.enterOverlayMode();
      } else {
        windowService.exitOverlayMode();
        // Phase just changed to working — start the safety-net timer in
        // case the normal exit path failed partway.
        windowService.startOverlayExitSafetyTimer();
      }
    }

    if (breakTimerService.preBreakWarning && !lastPreBreakWarning) {
      notificationService.showBreakWarning(
        breakTimerService.secondsUntilBreak,
      );
    }
    lastPreBreakWarning = breakTimerService.preBreakWarning;
  });

  // Create the tray service once and initialize it.
  final trayService = TrayService(
    settingsService: settingsService,
    breakTimerService: breakTimerService,
    windowService: windowService,
  );
  await trayService.init();

  runApp(ArgusApp(
    windowService: windowService,
    settingsService: settingsService,
    breakTimerService: breakTimerService,
    trayService: trayService,
    notificationService: notificationService,
  ));
}