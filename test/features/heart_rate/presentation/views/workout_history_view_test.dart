// Widget test for WorkoutHistoryView
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/workout_history_view.dart';

void main() {
  testWidgets('WorkoutHistoryView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WorkoutHistoryView())),
    );
    expect(find.byType(WorkoutHistoryView), findsOneWidget);
  });
}
