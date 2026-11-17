import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:argus/screens/break_overlay/break_overlay_screen.dart';
import 'package:argus/services/break_timer_service.dart';
import 'package:argus/services/settings_service.dart';
import 'package:argus/widgets/common/progress_ring.dart';

void main() {
  testWidgets('break ring empties exactly at the break deadline',
      (tester) async {
    var currentTime = DateTime(2024, 1, 1, 12, 0, 0);
    final settingsService = SettingsService();
    final timer = BreakTimerService(
      settingsService: settingsService,
      now: () => currentTime,
    );
    addTearDown(timer.dispose);

    timer.startBreakNow();

    // The overlay mounts 1.5 s after the break starts, like the real window
    // transition. 18.5 of 20 seconds remain.
    currentTime = currentTime.add(const Duration(milliseconds: 1500));
    timer.tick();

    await tester.pumpWidget(MaterialApp(
      home: BreakOverlayScreen(
        settings: settingsService,
        timer: timer,
      ),
    ));
    await tester.pump();

    ProgressRing ring() =>
        tester.widget<ProgressRing>(find.byType(ProgressRing));

    // 18.5 s rounds up to 19 on screen, and the ring starts at 92.5%.
    expect(find.text('19'), findsOneWidget);
    expect(ring().value, closeTo(0.925, 0.001));

    // 18 s later, 0.5 s of break remains: the ring is nearly empty.
    await tester.pump(const Duration(seconds: 18));
    expect(ring().value, closeTo(0.025, 0.001));

    // The last 0.5 s empties the ring exactly at the deadline.
    await tester.pump(const Duration(milliseconds: 500));
    expect(ring().value, closeTo(0.0, 0.001));
  });
}
