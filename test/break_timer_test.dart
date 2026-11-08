import 'package:flutter_test/flutter_test.dart';
import 'package:argus/services/break_timer_service.dart';
import 'package:argus/services/settings_service.dart';

void main() {
  late DateTime currentTime;
  late SettingsService settingsService;
  late BreakTimerService timer;

  setUp(() {
    currentTime = DateTime(2024, 1, 1, 12, 0, 0);
    settingsService = SettingsService();
    timer = BreakTimerService(
      settingsService: settingsService,
      now: () => currentTime,
    );
    timer.start();
  });

  tearDown(() {
    timer.dispose();
  });

  test('working to breakTime at the right moment', () {
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 20 * 60); // 1200 seconds

    // Advance 1 second at a time to keep tick gaps small (< 5s sleep threshold)
    for (var i = 0; i < 1199; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 1);

    // One more second — break starts
    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.phase, TimerPhase.breakTime);
    expect(timer.secondsLeftInBreak, 20); // default 20 second break
  });

  test('breakTime back to working', () {
    timer.startBreakNow();
    expect(timer.phase, TimerPhase.breakTime);
    expect(timer.secondsLeftInBreak, 20);

    for (var i = 0; i < 20; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 20 * 60); // fresh 20 min interval
  });

  test('preBreakWarning only when notifications are on', () {
    // Default: notifications on -> warning in last 10 seconds
    for (var i = 0; i < 1190; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.preBreakWarning, true);

    // Turn off notifications
    final s = settingsService.settings;
    settingsService.update(s.copyWith(showNotifications: false));
    timer.tick();
    expect(timer.preBreakWarning, false);

    // Turn back on — still in warning zone
    settingsService.update(s.copyWith(showNotifications: true));
    timer.tick();
    expect(timer.preBreakWarning, true);
  });

  test('skipBreak ignored when Skip Option is off', () {
    timer.startBreakNow();
    expect(timer.phase, TimerPhase.breakTime);

    // Turn off skip option
    final s = settingsService.settings;
    settingsService.update(s.copyWith(skipEnabled: false));
    timer.tick();

    timer.skipBreak();
    expect(timer.phase, TimerPhase.breakTime); // unchanged
  });

  test('skipBreak works when Skip Option is on', () {
    timer.startBreakNow();
    expect(timer.phase, TimerPhase.breakTime);

    timer.skipBreak();
    expect(timer.phase, TimerPhase.working);
  });

  test('pause keeps secondsUntilBreak unchanged and sets pausedUntil', () {
    // Advance 30 seconds so secondsUntilBreak is not the initial 1200
    for (var i = 0; i < 30; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    final secondsBeforePause = timer.secondsUntilBreak; // 1170
    expect(secondsBeforePause, 20 * 60 - 30);

    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.paused);
    expect(timer.pausedUntil, isNotNull);
    // secondsUntilBreak keeps its last real value
    expect(timer.secondsUntilBreak, secondsBeforePause);
  });

  test('pause during a break is ignored', () {
    timer.startBreakNow();
    expect(timer.phase, TimerPhase.breakTime);

    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.breakTime); // unchanged
  });

  test('pause when already paused is ignored', () {
    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.paused);

    final firstPausedUntil = timer.pausedUntil;
    timer.pauseForOneHour();
    expect(timer.pausedUntil, firstPausedUntil); // unchanged
  });

  test('resume while not paused does nothing', () {
    expect(timer.phase, TimerPhase.working);
    final before = timer.secondsUntilBreak;
    timer.resume();
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, before); // unchanged
  });

  test('pause at 19:20 then resume gives 19:20', () {
    // 19:20 remaining = 19 * 60 + 20 = 1160 seconds remaining (advanced 40 seconds)
    for (var i = 0; i < 40; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.secondsUntilBreak, 1160);

    // Pause at 19:20
    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.paused);
    expect(timer.secondsUntilBreak, 1160);

    // Resumed ten minutes later
    currentTime = currentTime.add(const Duration(minutes: 10));

    // Resume continues from 19:20 immediately, without waiting for a tick
    timer.resume();
    expect(timer.phase, TimerPhase.working);
    expect(timer.pausedUntil, isNull);
    expect(timer.secondsUntilBreak, 1160);

    // And continues counting down from 19:20 on subsequent ticks
    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.secondsUntilBreak, 1159);
  });

  test('automatic resume after the pause time gives the same remaining value', () {
    // Advance 40 seconds (1160s remaining)
    for (var i = 0; i < 40; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.secondsUntilBreak, 1160);

    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.paused);
    expect(timer.secondsUntilBreak, 1160);

    // Advance 1 hour — pause expires
    currentTime = currentTime.add(const Duration(hours: 1));
    timer.tick();

    expect(timer.phase, TimerPhase.working);
    expect(timer.pausedUntil, isNull);
    expect(timer.secondsUntilBreak, 1160);

    // Continues counting down from 1160
    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.secondsUntilBreak, 1159);
  });

  test('pausing with 5 seconds left then resuming turns the pre-break warning on if notifications are enabled', () {
    // Default: notifications enabled. Advance until 5 seconds remain (1195 seconds elapsed).
    for (var i = 0; i < 1195; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.secondsUntilBreak, 5);
    expect(timer.preBreakWarning, true);

    // Pause with 5 seconds left
    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.paused);
    expect(timer.secondsUntilBreak, 5);
    // preBreakWarning is false while paused because phase is not working
    expect(timer.preBreakWarning, false);

    // Advance 15 minutes and resume
    currentTime = currentTime.add(const Duration(minutes: 15));
    timer.resume();

    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 5);
    expect(timer.preBreakWarning, true);

    // If notifications were disabled, warning should be false
    final s = settingsService.settings;
    settingsService.update(s.copyWith(showNotifications: false));
    expect(timer.preBreakWarning, false);
  });

  test('pause and auto-resume after one hour', () {
    // Advance 50 seconds (1150s remaining)
    for (var i = 0; i < 50; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.secondsUntilBreak, 1150);

    timer.pauseForOneHour();
    expect(timer.phase, TimerPhase.paused);
    expect(timer.pausedUntil, isNotNull);

    // Tick while paused up to the 1-hour mark
    for (var i = 0; i < 899; i++) {
      currentTime = currentTime.add(const Duration(seconds: 4));
      timer.tick();
    }
    expect(timer.phase, TimerPhase.paused);

    // 4 seconds to the hour mark — pause expires, resume with remaining seconds
    currentTime = currentTime.add(const Duration(seconds: 4));
    timer.tick();
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 1150);
  });

  test('settings change applies only on next cycle', () {
    expect(timer.secondsUntilBreak, 20 * 60);

    // Change interval mid-countdown
    final s = settingsService.settings;
    settingsService.update(s.copyWith(breakIntervalMinutes: 5));
    timer.tick();

    // Still counting down from 20 minutes
    expect(timer.secondsUntilBreak, 20 * 60);

    // Run through break and back to working
    for (var i = 0; i < 1200; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.phase, TimerPhase.breakTime);

    for (var i = 0; i < 20; i++) {
      currentTime = currentTime.add(const Duration(seconds: 1));
      timer.tick();
    }
    expect(timer.phase, TimerPhase.working);

    // Now uses 5 minutes
    expect(timer.secondsUntilBreak, 5 * 60);
  });

  test('long sleep gap restarts the interval only while working', () {
    // Advance 1 second at a time to avoid spurious sleep detection
    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 20 * 60 - 1);

    // Simulate computer asleep for 10 seconds (gap > 5 second threshold)
    currentTime = currentTime.add(const Duration(seconds: 10));
    timer.tick();

    // Should restart working interval
    expect(timer.phase, TimerPhase.working);
    expect(timer.secondsUntilBreak, 20 * 60);
  });

  test('real timer decreases countdown over real time', () async {
    // Use real clock — no injectable now
    final realTimer = BreakTimerService(
      settingsService: SettingsService(),
    );
    realTimer.start();

    final initial = realTimer.secondsUntilBreak;

    // Wait about 3 real seconds
    await Future.delayed(const Duration(seconds: 3));

    expect(realTimer.phase, TimerPhase.working);
    expect(realTimer.secondsUntilBreak, lessThan(initial));
    expect(realTimer.secondsUntilBreak, greaterThan(initial - 5));

    realTimer.dispose();
  });

  test('tick advances countdown second by second with injectable clock', () {
    // Reset injectable clock and restart timer with fresh deadline
    currentTime = DateTime(2024, 1, 1, 12, 0, 0);
    timer.start();

    expect(timer.secondsUntilBreak, 20 * 60); // 1200

    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.secondsUntilBreak, 1199);

    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.secondsUntilBreak, 1198);

    currentTime = currentTime.add(const Duration(seconds: 1));
    timer.tick();
    expect(timer.secondsUntilBreak, 1197);
  });
}
