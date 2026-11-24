import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:argus/widgets/common/app_dropdown.dart';

/// The settings screen is laid out at 960x640 and scaled by FittedBox, while
/// the dropdown's popup lives in the unscaled overlay above it. This test
/// makes sure the popup is still positioned over the (scaled) control and
/// that its items can be tapped at the smallest and largest UI scale.
void main() {
  for (final scale in [0.7, 1.25]) {
    testWidgets('dropdown opens and selects at ${scale}x scale', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(960 * scale, 640 * scale);
      addTearDown(tester.view.reset);

      int? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 960,
                height: 640,
                child: Center(
                  child: AppDropdown<int>(
                    value: 100,
                    items: const [
                      AppDropdownItem(value: 70, label: '70%'),
                      AppDropdownItem(value: 100, label: '100% (Default)'),
                      AppDropdownItem(value: 125, label: '125%'),
                    ],
                    onChanged: (value) => selected = value,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppDropdown<int>));
      await tester.pumpAndSettle();

      // The menu item exists in the unscaled overlay and can be tapped.
      expect(find.text('70%'), findsOneWidget);
      await tester.tap(find.text('70%'));
      await tester.pumpAndSettle();
      expect(selected, 70);
    });
  }
}
