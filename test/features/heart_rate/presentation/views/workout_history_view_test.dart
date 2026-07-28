// Widget test for WorkoutHistoryView
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/workout_history_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

void main() {
  testWidgets('WorkoutHistoryView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const WorkoutHistoryView(),
        ),
      ),
    );
    expect(find.byType(WorkoutHistoryView), findsOneWidget);
  });
}
