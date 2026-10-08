import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pulse_track/core/application/service_providers.dart';
import 'package:pulse_track/core/navigation/app_router.dart';
import 'package:pulse_track/core/presentation/screens/biometric_shield_screen.dart';
import 'package:pulse_track/core/presentation/views/route_error_view.dart';
import 'package:pulse_track/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_home_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_scanner_view.dart';
import 'package:pulse_track/features/workout/presentation/views/workout_history_view.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_device_profile_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';
import 'package:pulse_track/features/settings/domain/models/user_settings.dart';
import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

class _MockHeartRateMonitorService extends Mock
    implements HeartRateMonitorService {}

class _MockBluetoothDevice extends Mock implements BluetoothDevice {}

class _MockForegroundServiceManager extends Mock
    implements ForegroundServiceManager {}

class _MockSaveDeviceProfileUseCase extends Mock
    implements SaveDeviceProfileUseCase {}

class _MockSaveWorkoutSessionUseCase extends Mock
    implements SaveWorkoutSessionUseCase {}

class _MockSavePartialWorkoutSessionUseCase extends Mock
    implements SavePartialWorkoutSessionUseCase {}

void main() {
  late _MockHeartRateMonitorService mockMonitorService;
  late _MockBluetoothDevice mockDevice;
  late _MockForegroundServiceManager mockForegroundManager;
  late _MockSaveDeviceProfileUseCase mockSaveDeviceProfileUseCase;
  late _MockSaveWorkoutSessionUseCase mockSaveWorkoutSessionUseCase;
  late _MockSavePartialWorkoutSessionUseCase
  mockSavePartialWorkoutSessionUseCase;

  setUp(() {
    mockMonitorService = _MockHeartRateMonitorService();
    mockDevice = _MockBluetoothDevice();
    mockForegroundManager = _MockForegroundServiceManager();
    mockSaveDeviceProfileUseCase = _MockSaveDeviceProfileUseCase();
    mockSaveWorkoutSessionUseCase = _MockSaveWorkoutSessionUseCase();
    mockSavePartialWorkoutSessionUseCase =
        _MockSavePartialWorkoutSessionUseCase();

    when(() => mockDevice.remoteId)
        .thenReturn(const DeviceIdentifier('AA:BB:CC:DD:EE:FF'));
    when(() => mockMonitorService.fromId('AA:BB:CC:DD:EE:FF'))
        .thenReturn(mockDevice);
    when(() => mockMonitorService.connect(mockDevice, autoConnect: false))
        .thenAnswer((_) async {});
    when(() => mockMonitorService.discoverServices(mockDevice))
        .thenAnswer((_) async => []);
    when(() => mockMonitorService.connectionState(mockDevice))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockMonitorService.disconnect(mockDevice))
        .thenAnswer((_) async {});
    when(() => mockForegroundManager.startService()).thenAnswer((_) async {});
    when(() => mockForegroundManager.stopService()).thenAnswer((_) async {});
  });

  ProviderContainer createContainer({
    UserSettings settings = const UserSettings(isOnboardingCompleted: true),
  }) {
    return ProviderContainer(
      overrides: [
        watchSavedDeviceProfilesStreamProvider.overrideWithValue(
          const AsyncValue<List<DeviceProfile>>.data([]),
        ),
        watchWorkoutHistoryStreamProvider.overrideWithValue(
          const AsyncValue<List<WorkoutSession>>.data([]),
        ),
        heartRateMonitorServiceProvider.overrideWithValue(mockMonitorService),
        foregroundServiceManagerProvider.overrideWithValue(
          mockForegroundManager,
        ),
        saveDeviceProfileUseCaseProvider.overrideWithValue(
          mockSaveDeviceProfileUseCase,
        ),
        saveWorkoutSessionUseCaseProvider.overrideWithValue(
          mockSaveWorkoutSessionUseCase,
        ),
        savePartialWorkoutSessionUseCaseProvider.overrideWithValue(
          mockSavePartialWorkoutSessionUseCase,
        ),
        appSettingsProvider.overrideWithValue(settings),
      ],
    );
  }

  Widget buildTestApp(ProviderContainer container) {
    final router = container.read(appRouterProvider);
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    );
  }

  group('AppRouter Deep Link & Route Matching', () {
    testWidgets('initial location "/" renders HrHomeView', (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(HrHomeView), findsOneWidget);
    });

    testWidgets('route "/scanner" renders HrScannerView', (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(appRouterProvider).go('/scanner');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(HrScannerView), findsOneWidget);
    });

    testWidgets('route "/monitor" parses query parameters correctly', (
      tester,
    ) async {
      final container = createContainer();
      addTearDown(container.dispose);

      const deviceId = 'AA:BB:CC:DD:EE:FF';
      const deviceName = 'Polar H10';
      final encodedId = Uri.encodeComponent(deviceId);
      final encodedName = Uri.encodeComponent(deviceName);

      container
          .read(appRouterProvider)
          .go('/monitor?deviceId=$encodedId&deviceName=$encodedName');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(HrMonitorView), findsOneWidget);
      final monitorWidget = tester.widget<HrMonitorView>(
        find.byType(HrMonitorView),
      );
      expect(monitorWidget.deviceId, deviceId);
      expect(monitorWidget.deviceName, deviceName);
    });

    testWidgets('route "/history" renders WorkoutHistoryView', (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(appRouterProvider).go('/history');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutHistoryView), findsOneWidget);
    });

    testWidgets(
      'unknown route "/invalid_route" renders RouteErrorView fallback',
      (tester) async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.read(appRouterProvider).go('/invalid_route');
        await tester.pumpWidget(buildTestApp(container));
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorView), findsOneWidget);
        expect(find.text('Navigation Error'), findsOneWidget);
        expect(find.text('Back to home'), findsOneWidget);
      },
    );

    testWidgets(
      'route "/history/details" without sessionId parameter triggers RouteErrorView fallback',
      (tester) async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.read(appRouterProvider).go('/history/details');
        await tester.pumpWidget(buildTestApp(container));
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorView), findsOneWidget);
      },
    );
  });

  group('AppRouter redirect (lock and onboarding gates)', () {
    testWidgets('locked app redirects initial "/" to "/shield"', (
      tester,
    ) async {
      final container = createContainer(
        settings: const UserSettings(
          isOnboardingCompleted: true,
          isLocked: true,
        ),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(BiometricShieldScreen), findsOneWidget);
      expect(find.byType(HrHomeView), findsNothing);
    });

    testWidgets('locked app redirects "/history" to "/shield"', (tester) async {
      final container = createContainer(
        settings: const UserSettings(
          isOnboardingCompleted: true,
          isLocked: true,
        ),
      );
      addTearDown(container.dispose);

      container.read(appRouterProvider).go('/history');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(BiometricShieldScreen), findsOneWidget);
    });

    testWidgets('locked app stays on "/shield" without redirect loop', (
      tester,
    ) async {
      final container = createContainer(
        settings: const UserSettings(
          isOnboardingCompleted: true,
          isLocked: true,
        ),
      );
      addTearDown(container.dispose);

      container.read(appRouterProvider).go('/shield');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(BiometricShieldScreen), findsOneWidget);
    });

    testWidgets(
      'incomplete onboarding redirects initial "/" to "/onboarding"',
      (tester) async {
        final container = createContainer(settings: const UserSettings());
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestApp(container));
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(HrHomeView), findsNothing);
      },
    );

    testWidgets('completed onboarding redirects "/onboarding" back to "/"', (
      tester,
    ) async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(appRouterProvider).go('/onboarding');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(HrHomeView), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('unlocked shield route redirects to "/"', (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(appRouterProvider).go('/shield');
      await tester.pumpWidget(buildTestApp(container));
      await tester.pumpAndSettle();

      expect(find.byType(HrHomeView), findsOneWidget);
      expect(find.byType(BiometricShieldScreen), findsNothing);
    });
  });
}
