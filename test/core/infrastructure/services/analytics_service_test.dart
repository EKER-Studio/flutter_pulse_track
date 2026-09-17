import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/infrastructure/services/analytics_service.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late _MockFirebaseAnalytics mockAnalytics;
  late AnalyticsService serviceWithMock;
  late AnalyticsService serviceWithoutMock;

  setUp(() {
    mockAnalytics = _MockFirebaseAnalytics();
    serviceWithMock = AnalyticsService(analytics: mockAnalytics);
    serviceWithoutMock = AnalyticsService();
  });

  group('AnalyticsService without analytics instance (safe fallback)', () {
    test('setCollectionEnabled completes normally without throwing', () async {
      await expectLater(
        serviceWithoutMock.setCollectionEnabled(true),
        completes,
      );
    });

    test('logWorkoutStarted completes normally without throwing', () async {
      await expectLater(
        serviceWithoutMock.logWorkoutStarted(sport: 'running'),
        completes,
      );
    });

    test('logWorkoutCompleted completes normally without throwing', () async {
      await expectLater(
        serviceWithoutMock.logWorkoutCompleted(durationSeconds: 1800),
        completes,
      );
    });

    test('logDeviceConnected completes normally without throwing', () async {
      await expectLater(serviceWithoutMock.logDeviceConnected(), completes);
    });

    test('logExportShared completes normally without throwing', () async {
      await expectLater(
        serviceWithoutMock.logExportShared(format: 'csv', sessionCount: 3),
        completes,
      );
    });
  });

  group('AnalyticsService with mocked FirebaseAnalytics', () {
    test('setCollectionEnabled forwards call to FirebaseAnalytics', () async {
      when(() => mockAnalytics.setAnalyticsCollectionEnabled(any()))
          .thenAnswer((_) async {});

      await serviceWithMock.setCollectionEnabled(true);

      verify(() => mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
    });

    test(
      'logWorkoutStarted logs workout_started event with parameters',
      () async {
        when(
          () => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {});

        await serviceWithMock.logWorkoutStarted(sport: 'cycling');

        verify(
          () => mockAnalytics.logEvent(
            name: 'workout_started',
            parameters: {'sport': 'cycling'},
          ),
        ).called(1);
      },
    );

    test('logWorkoutStarted omits the sport key when sport is null', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      await serviceWithMock.logWorkoutStarted();

      verify(
        () => mockAnalytics.logEvent(name: 'workout_started', parameters: {}),
      ).called(1);
    });

    test(
      'logWorkoutCompleted logs workout_completed event with parameters',
      () async {
        when(
          () => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {});

        await serviceWithMock.logWorkoutCompleted(durationSeconds: 3600);

        verify(
          () => mockAnalytics.logEvent(
            name: 'workout_completed',
            parameters: {'duration_seconds': 3600},
          ),
        ).called(1);
      },
    );

    test(
      'logDeviceConnected logs device_connected event with parameters',
      () async {
        when(
          () => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {});

        await serviceWithMock.logDeviceConnected();

        verify(() => mockAnalytics.logEvent(name: 'device_connected'))
            .called(1);
      },
    );

    test('logExportShared logs export_shared event with parameters', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      await serviceWithMock.logExportShared(format: 'csv', sessionCount: 5);

      verify(
        () => mockAnalytics.logEvent(
          name: 'export_shared',
          parameters: {'format': 'csv', 'session_count': 5},
        ),
      ).called(1);
    });
  });

  group('Analytics Providers', () {
    test(
      'analyticsServiceProvider resolves safely when Firebase is uninitialized',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final service = container.read(analyticsServiceProvider);
        expect(service, isA<AnalyticsService>());
      },
    );

    test('analyticsObserverProvider resolves to null safely when Firebase is uninitialized', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final observer = container.read(analyticsObserverProvider);
      expect(observer, isNull);
    });
  });
}
