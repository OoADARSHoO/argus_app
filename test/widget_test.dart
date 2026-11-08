import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:argus/app.dart';
import 'package:argus/screens/settings/about_page.dart';
import 'package:argus/screens/settings/appearance_page.dart';
import 'package:argus/screens/settings/break_page.dart';
import 'package:argus/screens/settings/general_page.dart';
import 'package:argus/screens/settings/support_page.dart';
import 'package:argus/services/break_timer_service.dart';
import 'package:argus/services/settings_service.dart';
import 'package:argus/services/window_service.dart';
import 'package:argus/widgets/sidebar/sidebar_nav.dart';
import 'package:argus/widgets/titlebar/custom_title_bar.dart';

void main() {
  testWidgets('Smoke test: SettingsShell renders titlebar, sidebar, and pages', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settingsService = SettingsService();
    final windowService = WindowService();
    final breakTimerService = BreakTimerService(
      settingsService: settingsService,
    );

    await tester.pumpWidget(ArgusApp(
      windowService: windowService,
      settingsService: settingsService,
      breakTimerService: breakTimerService,
    ));
    await tester.pumpAndSettle();

    // Verify Title Bar
    expect(find.byType(CustomTitleBar), findsOneWidget);
    expect(find.text('ARGUS'), findsWidgets);

    // Verify Sidebar
    expect(find.byType(SidebarNav), findsOneWidget);
    expect(find.text('General'), findsWidgets);
    expect(find.text('Break'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // Initial page is GeneralPage
    expect(find.byType(GeneralPage), findsOneWidget);
    expect(find.text('Break Interval'), findsOneWidget);
    expect(find.text('Break Duration'), findsOneWidget);

    // Switch to Break tab
    await tester.tap(find.text('Break'));
    await tester.pumpAndSettle();
    expect(find.byType(BreakPage), findsOneWidget);
    expect(find.text('Break Message'), findsOneWidget);

    // Switch to Appearance tab
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    expect(find.byType(AppearancePage), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Switch to Support tab
    await tester.tap(find.text('Support'));
    await tester.pumpAndSettle();
    expect(find.byType(SupportPage), findsOneWidget);
    expect(find.text(r'$128 / $200'), findsOneWidget);

    // Switch to About tab
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });
}
