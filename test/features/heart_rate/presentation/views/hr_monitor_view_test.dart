// Widget test for HrMonitorView
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';

void main() {
  testWidgets('HrMonitorView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HrMonitorView(deviceId: 'test-id', deviceName: 'Test Device'),
        ),
      ),
    );
    expect(find.byType(HrMonitorView), findsOneWidget);
  });
}
