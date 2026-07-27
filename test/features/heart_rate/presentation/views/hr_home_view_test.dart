// Widget test for HrHomeView
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';

void main() {
  testWidgets('HrHomeView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HrHomeView())),
    );
    expect(find.byType(HrHomeView), findsOneWidget);
  });
}
