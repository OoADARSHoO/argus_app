import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/settings_service.dart';

/// Debug flag: when true, work = 30 seconds and break = 10 seconds regardless
/// of settings, so a full cycle can be watched quickly.
const bool kDebugShortTimers = false;

/// Phases of the 20-20-20 cycle.
enum TimerPhase {
  working,   // Counting down until the next break
  breakTime, // Currently in a break, counting down until it ends
  paused,    // Cycle suspended (e.g. "Pause for 1 hour")
}

/// Owns the 20-20-20 timing cycle.
///
/// Reads interval, duration, skip option, and notification flag from
/// [SettingsService]. Changes to interval or duration apply from the NEXT
/// cycle, never mid-countdown.
///
/// Uses a [Timer.periodic] that recomputes remaining time from a
/// [DateTime] deadline on every tick, so it cannot drift. If the computer
/// was asleep (more than ~5 seconds between ticks), the working interval
/// restarts instead of firing a stale break.
///
/// The clock is injectable for testing. Use [tick] to drive time manually
/// in tests.
class BreakTimerService extends ChangeNotifier {
  static const Duration _tickInterval = Duration(seconds: 1);
  /// If the gap between two ticks exceeds this, treat it as a sleep wake-up
  /// and restart the working interval.
  static const Duration _sleepGapThreshold = Duration(seconds: 5);

  final SettingsService settingsService;
  final DateTime Function() now;

  TimerPhase _phase = TimerPhase.working;
  DateTime? _workingDeadline;
  DateTime? _breakDeadline;
  DateTime? _pausedUntil;
  /// Remaining working seconds stored at the moment of pausing.
  /// Kept while paused, and used to resume countdown from where it left off.
  int? _pausedRemainingSeconds;
  DateTime _lastTickTime = DateTime.now();
  Timer? _timer;

  BreakTimerService({
    required this.settingsService,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  //--------------------------------------------------------------------------
  // Read-only state
  //--------------------------------------------------------------------------

  TimerPhase get phase => _phase;

  /// Seconds remaining until the next break starts (working phase only).
  /// While paused, returns the stored remaining seconds at the moment of pausing.
  int get secondsUntilBreak {
    if (_phase == TimerPhase.paused) {
      return _pausedRemainingSeconds ?? 0;
    }
    if (_phase != TimerPhase.working || _workingDeadline == null) return 0;
    return _workingDeadline!.difference(now()).inSeconds.clamp(0, 1 << 30);
  }

  /// Seconds remaining in the current break (breakTime phase only).
  int get secondsLeftInBreak {
    if (_phase != TimerPhase.breakTime || _breakDeadline == null) return 0;
    return _breakDeadline!.difference(now()).inSeconds.clamp(0, 1 << 30);
  }

  /// True during the last 10 seconds of working, only if Show Notifications
  /// is enabled.
  bool get preBreakWarning {
    if (_phase != TimerPhase.working) return false;
    if (!settingsService.settings.showNotifications) return false;
    return secondsUntilBreak <= 10;
  }

  /// When the pause expires (paused phase only). Null when not paused.
  DateTime? get pausedUntil => _pausedUntil;

  //--------------------------------------------------------------------------
  // Derived config (honors kDebugShortTimers)
  //--------------------------------------------------------------------------

  int get _workIntervalSeconds {
    if (kDebugShortTimers) return 30;
    return settingsService.settings.breakIntervalMinutes * 60;
  }

  int get _breakDurationSeconds {
    if (kDebugShortTimers) return 10;
    return settingsService.settings.breakDurationSeconds;
  }

  bool get _skipEnabled {
    if (kDebugShortTimers) return true;
    return settingsService.settings.skipEnabled;
  }

  /// Pause duration: 20 seconds in short-timer debug mode, 1 hour normally.
  Duration get _pauseDuration {
    if (kDebugShortTimers) return const Duration(seconds: 20);
    return const Duration(hours: 1);
  }

  //--------------------------------------------------------------------------
  // Lifecycle
  //--------------------------------------------------------------------------

  /// Start the timer from scratch. Begins a fresh working interval.
  void start() {
    _stopTimer();
    _lastTickTime = now();
    _scheduleNextWorkingDeadline();
    _pausedUntil = null;
    _pausedRemainingSeconds = null;
    _phase = TimerPhase.working;
    _startTimer();
    notifyListeners();
  }

  void _scheduleNextWorkingDeadline() {
    _workingDeadline = now().add(Duration(seconds: _workIntervalSeconds));
    _breakDeadline = null;
  }

  void _scheduleNextBreakDeadline() {
    _breakDeadline = now().add(Duration(seconds: _breakDurationSeconds));
    _workingDeadline = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(_tickInterval, (_) => _recompute());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Public entry point for tests to drive time manually.
  /// Equivalent to one timer tick.
  void tick() {
    _recompute();
  }

  //--------------------------------------------------------------------------
  // Internal tick logic (runs every second, or on manual tick)
  //--------------------------------------------------------------------------

  void _recompute() {
    final currentTime = now();
    final gap = currentTime.difference(_lastTickTime);
    _lastTickTime = currentTime;

    // Sleep detection applies only while working. A large gap means the
    // computer was asleep, so restart the working interval instead of firing
    // a stale break.
    if (_phase == TimerPhase.working && gap > _sleepGapThreshold) {
      _pausedUntil = null;
      _pausedRemainingSeconds = null;
      _scheduleNextWorkingDeadline();
      notifyListeners();
      return;
    }

    switch (_phase) {
      case TimerPhase.working:
        _tickWorking(currentTime);
        break;
      case TimerPhase.breakTime:
        _tickBreakTime(currentTime);
        break;
      case TimerPhase.paused:
        _tickPaused(currentTime);
        break;
    }
  }

  void _tickWorking(DateTime currentTime) {
    if (_workingDeadline == null) return;
    final remaining = _workingDeadline!.difference(currentTime).inSeconds;
    if (remaining <= 0) {
      _phase = TimerPhase.breakTime;
      _scheduleNextBreakDeadline();
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void _tickBreakTime(DateTime currentTime) {
    if (_breakDeadline == null) return;
    final remaining = _breakDeadline!.difference(currentTime).inSeconds;
    if (remaining <= 0) {
      _phase = TimerPhase.working;
      _scheduleNextWorkingDeadline();
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  /// While paused, checks whether [pausedUntil] has passed. If it has,
  /// takes the same resume path as [resume]. Does NOT touch
  /// [secondsUntilBreak] while still paused.
  void _tickPaused(DateTime currentTime) {
    if (_pausedUntil == null) return;
    if (currentTime.isAfter(_pausedUntil!) ||
        currentTime.isAtSameMomentAs(_pausedUntil!)) {
      _resumeCycle();
    } else {
      notifyListeners();
    }
  }

  /// Shared resume path used by both [resume] and automatic resume after the
  /// pause expires. Continues from the stored remaining working seconds.
  void _resumeCycle() {
    final remaining = _pausedRemainingSeconds ?? _workIntervalSeconds;
    _phase = TimerPhase.working;
    _pausedUntil = null;
    _pausedRemainingSeconds = null;
    _breakDeadline = null;
    _workingDeadline = now().add(Duration(seconds: remaining));
    _lastTickTime = now();
    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Public actions
  //--------------------------------------------------------------------------

  /// Skip the current break. Only valid during breakTime and only if the
  /// Skip Option setting is on.
  void skipBreak() {
    if (_phase != TimerPhase.breakTime) return;
    if (!_skipEnabled) return;
    _phase = TimerPhase.working;
    _breakDeadline = null;
    _pausedRemainingSeconds = null;
    _scheduleNextWorkingDeadline();
    notifyListeners();
  }

  /// Suspend the cycle. Only valid while the phase is [TimerPhase.working].
  /// Ignored during a break or when already paused.
  ///
  /// Stores the remaining working seconds in [_pausedRemainingSeconds], sets
  /// [phase] to [TimerPhase.paused], and sets [pausedUntil] to now + pause duration.
  /// [secondsUntilBreak] remains unchanged while paused.
  void pauseForOneHour() {
    if (_phase != TimerPhase.working) return;
    // Capture the current countdown value at the moment of pausing.
    _pausedRemainingSeconds = secondsUntilBreak;
    _phase = TimerPhase.paused;
    _pausedUntil = now().add(_pauseDuration);
    notifyListeners();
  }

  /// Resume from a paused state. Only valid when [phase] is [TimerPhase.paused].
  /// Continues from the stored countdown value immediately.
  void resume() {
    if (_phase != TimerPhase.paused) return;
    _resumeCycle();
  }

  /// Immediately enter breakTime. Useful for testing.
  void startBreakNow() {
    _phase = TimerPhase.breakTime;
    _workingDeadline = null;
    _pausedUntil = null;
    _pausedRemainingSeconds = null;
    _scheduleNextBreakDeadline();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
