import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:argus/core/constants/app_colors.dart';
import 'package:argus/core/theme/app_palette.dart';
import 'package:argus/core/theme/app_theme.dart';
import 'package:argus/screens/break_overlay/break_overlay_screen.dart';
import 'package:argus/screens/settings/settings_shell.dart';
import 'package:argus/services/break_timer_service.dart';
import 'package:argus/services/notification_service.dart';
import 'package:argus/services/settings_service.dart';
import 'package:argus/services/tray_service.dart';
import 'package:argus/services/update_service.dart';
import 'package:argus/services/window_service.dart';
import 'package:argus/widgets/common/progress_ring.dart';

/// Builds the service graph the settings shell needs, without touching the
/// platform (no window_manager, tray, or notification initialization).
({
  WindowService windowService,
  SettingsService settingsService,
  BreakTimerService breakTimerService,
  TrayService trayService,
  NotificationService notificationService,
  UpdateService updateService,
}) _services() {
  final settingsService = SettingsService();
  final windowService = WindowService();
  final breakTimerService = BreakTimerService(
    settingsService: settingsService,
  );
  final trayService = TrayService(
    settingsService: settingsService,
    breakTimerService: breakTimerService,
    windowService: windowService,
  );
  final notificationService = NotificationService();
  final updateService = UpdateService(
    settingsService: settingsService,
    windowService: windowService,
    breakTimerService: breakTimerService,
    trayService: trayService,
    notificationService: notificationService,
    onExit: () {},
  );
  return (
    windowService: windowService,
    settingsService: settingsService,
    breakTimerService: breakTimerService,
    trayService: trayService,
    notificationService: notificationService,
    updateService: updateService,
  );
}

void main() {
  test('themeModeForId maps saved theme ids and falls back to dark', () {
    expect(AppTheme.themeModeForId('dark'), ThemeMode.dark);
    expect(AppTheme.themeModeForId('light'), ThemeMode.light);
    expect(AppTheme.themeModeForId('system'), ThemeMode.system);

    // Unknown or empty values must never leave the app themeless. Dark is the
    // app default, so a corrupted settings file keeps the old look.
    expect(AppTheme.themeModeForId('nonsense'), ThemeMode.dark);
    expect(AppTheme.themeModeForId(''), ThemeMode.dark);
  });

  testWidgets('settings shell paints light and dark palette colors',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final services = _services();

    Future<void> pumpShell(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: SettingsShell(
          windowService: services.windowService,
          settingsService: services.settingsService,
          breakTimerService: services.breakTimerService,
          trayService: services.trayService,
          notificationService: services.notificationService,
          updateService: services.updateService,
        ),
      ));
      await tester.pumpAndSettle();
    }

    await pumpShell(AppTheme.darkTheme());
    final darkScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(darkScaffold.backgroundColor, AppPalette.dark.background);

    // Every page heading uses palette.textPrimary, so this also proves text
    // colors come from the theme rather than a baked-in dark style.
    expect(
      tester
          .widgetList<Text>(find.text('General'))
          .map((text) => text.style?.color),
      contains(AppPalette.dark.textPrimary),
    );

    await pumpShell(AppTheme.lightTheme());
    final lightScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(lightScaffold.backgroundColor, AppPalette.light.background);
    expect(
      tester
          .widgetList<Text>(find.text('General'))
          .map((text) => text.style?.color),
      contains(AppPalette.light.textPrimary),
    );

    // The two themes must actually differ, not just carry a different
    // extension object.
    expect(lightScaffold.backgroundColor, isNot(darkScaffold.backgroundColor));
  });

  testWidgets('break overlay keeps fixed dark colors under both themes',
      (tester) async {
    var currentTime = DateTime(2024, 1, 1, 12, 0, 0);
    final settingsService = SettingsService();
    final timer = BreakTimerService(
      settingsService: settingsService,
      now: () => currentTime,
    );
    addTearDown(timer.dispose);

    timer.startBreakNow();
    currentTime = currentTime.add(const Duration(milliseconds: 1500));
    timer.tick();

    final breakSettings = settingsService.settings.breakSettings;
    final expectedBackground =
        AppColors.breakBackgroundForId(breakSettings.backgroundId);
    final expectedTextColor = Color(breakSettings.textColor);

    Future<void> pumpOverlay(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: BreakOverlayScreen(
          settings: settingsService,
          timer: timer,
        ),
      ));
      await tester.pump();
    }

    Future<void> expectFixedDarkColors() async {
      final material = tester.widget<Material>(find.byType(Material).first);
      expect(material.color, expectedBackground);

      final ring = tester.widget<ProgressRing>(find.byType(ProgressRing));
      expect(ring.color, expectedTextColor);
      // The track is hard-wired to the dark border instead of the active
      // palette, so a light settings theme cannot leak into the overlay.
      expect(ring.trackColor, AppPalette.dark.border);

      final skipText = tester.widget<Text>(find.text('Skip (Esc)'));
      expect(skipText.style?.color, AppPalette.dark.textPrimary);
    }

    await pumpOverlay(AppTheme.darkTheme());
    await expectFixedDarkColors();

    // Rebuild the overlay from scratch under the light theme. It must look
    // exactly the same as in dark mode.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpOverlay(AppTheme.lightTheme());
    await expectFixedDarkColors();

    // Dispose the overlay (and its running ring animation) before the test
    // ends so no ticker is left active.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
