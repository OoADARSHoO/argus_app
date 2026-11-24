import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:argus/app.dart';
import 'package:argus/core/constants/app_dimensions.dart';
import 'package:argus/models/appearance_settings.dart';
import 'package:argus/screens/settings/appearance_page.dart';
import 'package:argus/services/break_timer_service.dart';
import 'package:argus/services/notification_service.dart';
import 'package:argus/services/settings_service.dart';
import 'package:argus/services/tray_service.dart';
import 'package:argus/services/update_service.dart';
import 'package:argus/services/window_service.dart';
import 'package:argus/widgets/common/app_dropdown.dart';

/// The settings UI is laid out at 960x640 and scaled to the window. The
/// Navigator and its overlay live inside that wrapper too, so a dropdown's
/// popup menu is scaled exactly like the page that opened it.
///
/// Measuring a menu item's global (painted) height and comparing it with its
/// local layout height proves the popup is inside the scaled subtree. Before
/// the fix the popup was drawn by the unscaled Navigator, so the two heights
/// were equal at every UI scale.
void main() {
  for (final percent in AppearanceSettings.uiScaleOptions) {
    final scale = percent / 100;
    testWidgets('AppDropdown popup follows the UI scale at $percent%', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(
        AppDimensions.windowWidth * scale,
        AppDimensions.windowHeight * scale,
      );
      addTearDown(tester.view.reset);

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

      await tester.pumpWidget(
        ArgusApp(
          windowService: windowService,
          settingsService: settingsService,
          breakTimerService: breakTimerService,
          trayService: trayService,
          notificationService: notificationService,
          updateService: updateService,
        ),
      );
      await tester.pumpAndSettle();

      // The Appearance page has the UI Scale dropdown. Its current value is
      // the default 100%, so "70%" only exists inside the open popup.
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      expect(find.byType(AppearancePage), findsOneWidget);

      await tester.tap(find.byType(AppDropdown<int>));
      await tester.pumpAndSettle();

      final menuItem = find
          .ancestor(of: find.text('70%'), matching: find.byType(InkWell))
          .first;
      expect(menuItem, findsOneWidget);

      // getSize() is the local layout size (inside the FittedBox, always at
      // the base 960x640 layout). getTopLeft()/getBottomRight() are the
      // painted window coordinates, so their difference includes the scale.
      final renderedHeight =
          tester.getBottomRight(menuItem).dy - tester.getTopLeft(menuItem).dy;
      final layoutHeight = tester.getSize(menuItem).height;

      expect(renderedHeight, greaterThan(0));
      expect(renderedHeight, closeTo(layoutHeight * scale, 0.1));

      // The scaled menu must also be clickable where it is drawn.
      await tester.tap(find.text('70%'));
      await tester.pumpAndSettle();
      expect(settingsService.settings.appearanceSettings.uiScale, 70);

      // Let SettingsService's debounced save timer fire so no timer is left
      // pending when the test ends.
      await tester.pump(const Duration(milliseconds: 500));
    });
  }
}
