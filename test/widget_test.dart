import 'package:flutter_test/flutter_test.dart';
import 'package:argus/app.dart';
import 'package:argus/widgets/common/primary_button.dart';
import 'package:argus/widgets/common/app_toggle.dart';
import 'package:argus/widgets/common/progress_ring.dart';

void main() {
  testWidgets('Smoke test: ArgusApp renders demo page and widgets', (WidgetTester tester) async {
    await tester.pumpWidget(const ArgusApp());
    await tester.pumpAndSettle();

    expect(find.text('Phase 2: Shared Widgets Gallery'), findsOneWidget);
    expect(find.byType(PrimaryButton), findsWidgets);
    expect(find.byType(AppToggle), findsWidgets);
    expect(find.byType(ProgressRing), findsWidgets);
  });
}

