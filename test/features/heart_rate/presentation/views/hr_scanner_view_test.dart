// Widget test for HrScannerView
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';

void main() {
  testWidgets('HrScannerView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HrScannerView())),
    );
    expect(find.byType(HrScannerView), findsOneWidget);
  });
}
