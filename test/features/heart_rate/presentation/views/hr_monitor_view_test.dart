// Widget test for HrMonitorView
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart';
import 'package:pulse_track/features/heart_rate/presentation/views/hr_monitor_view.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_device_profile_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';
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
        .thenReturn(const DeviceIdentifier('test-id'));
    when(() => mockMonitorService.fromId('test-id')).thenReturn(mockDevice);
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

  testWidgets('HrMonitorView renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HrMonitorView(deviceId: 'test-id', deviceName: 'Test Device'),
        ),
      ),
    );

    expect(find.byType(HrMonitorView), findsOneWidget);
  });
}
