// Widget tests for WorkoutDetailsView.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/infrastructure/services/workout_export_share_service.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_details_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

class _MockWorkoutExportShareService extends Mock
    implements WorkoutExportShareService {}

WorkoutSession _makeSession() => WorkoutSession(
  id: 7,
  startTime: DateTime(2026, 9, 1, 10, 0),
  endTime: DateTime(2026, 9, 1, 10, 30),
  avgBpm: 132,
  maxBpm: 168,
  bpmSamples: List<int>.generate(60, (i) => 120 + (i % 20)),
  sensorLocationIndex: 1,
  deviceMacAddress: 'AA:BB:CC:DD:EE:01',
  deviceName: 'Polar H10',
);

Future<void> _pumpDetails(
  WidgetTester tester,
  WorkoutExportShareService shareService,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        workoutExportShareServiceProvider.overrideWithValue(shareService),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: WorkoutDetailsView(session: _makeSession()),
      ),
    ),
  );
}

void main() {
  late _MockWorkoutExportShareService mockShareService;

  setUpAll(() {
    registerFallbackValue(_makeSession());
  });

  setUp(() {
    mockShareService = _MockWorkoutExportShareService();
  });

  testWidgets('renders header, summary metrics, and share action', (
    WidgetTester tester,
  ) async {
    await _pumpDetails(tester, mockShareService);
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutDetailsView), findsOneWidget);
    expect(find.text('Workout Details'), findsOneWidget);
    expect(find.textContaining('132'), findsWidgets);
    expect(find.textContaining('168'), findsWidgets);
    expect(find.byIcon(Icons.share), findsOneWidget);
  });

  testWidgets('share button exports the displayed session', (
    WidgetTester tester,
  ) async {
    when(
      () => mockShareService.exportAndShareSession(
        any(),
        shareText: any(named: 'shareText'),
      ),
    ).thenAnswer((_) async {});
    await _pumpDetails(tester, mockShareService);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    verify(
      () => mockShareService.exportAndShareSession(
        any(),
        shareText: any(named: 'shareText'),
      ),
    ).called(1);
  });

  testWidgets('failed export shows an error SnackBar', (
    WidgetTester tester,
  ) async {
    when(
      () => mockShareService.exportAndShareSession(
        any(),
        shareText: any(named: 'shareText'),
      ),
    ).thenThrow(Exception('share sheet unavailable'));
    await _pumpDetails(tester, mockShareService);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.share));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Failed to export'), findsOneWidget);
  });
}
