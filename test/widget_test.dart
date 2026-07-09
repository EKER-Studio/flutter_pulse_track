// Smoke test verifying the top-level App widget can be built inside a
// ProviderScope without throwing. Full feature tests live in dedicated
// test files per feature module.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ble_heart_rate_monitor/app.dart';

void main() {
  testWidgets('App widget smoke test — builds without throwing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    // Verify the app scaffolds at least one widget.
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}

