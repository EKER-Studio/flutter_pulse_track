import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/integrations/health/health_service.dart';
import 'package:pulse_track/core/integrations/health/platform_detector.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

class MockHealthPlugin extends Mock implements Health {}

class MockPlatformDetector extends Mock implements PlatformDetector {}

const MethodChannel _permissionMethodChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

const MethodChannel _urlLauncherChannel = MethodChannel(
  'plugins.flutter.io/url_launcher',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthPlugin mockHealth;
  late MockPlatformDetector mockPlatformDetector;
  late NativeHealthService service;

  final List<String> launchedUrls = [];
  bool shouldLaunchFail = false;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(HealthDataType.HEART_RATE);
    registerFallbackValue(HealthDataUnit.BEATS_PER_MINUTE);
    registerFallbackValue(HealthWorkoutActivityType.OTHER);
    registerFallbackValue(RecordingMethod.manual);
    registerFallbackValue(const [HealthDataType.HEART_RATE]);
    registerFallbackValue(const [HealthDataAccess.READ]);
  });

  setUp(() {
    mockHealth = MockHealthPlugin();
    mockPlatformDetector = MockPlatformDetector();
    service = NativeHealthService(
      health: mockHealth,
      platformDetector: mockPlatformDetector,
    );

    launchedUrls.clear();
    shouldLaunchFail = false;

    when(() => mockHealth.configure()).thenAnswer((_) async {});
    when(() => mockPlatformDetector.isAndroid).thenReturn(false);
    when(() => mockPlatformDetector.isIOS).thenReturn(true);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionMethodChannel, (call) async {
          if (call.method == 'openAppSettings') {
            return true;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_urlLauncherChannel, (call) async {
          if (shouldLaunchFail) {
            return false;
          }
          if (call.method == 'launch') {
            final url = (call.arguments as Map)['url'] as String;
            launchedUrls.add(url);
            return true;
          }
          return false;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionMethodChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_urlLauncherChannel, null);
  });

  group('NativePlatformDetector', () {
    test('instantiates and provides platform booleans', () {
      const detector = NativePlatformDetector();
      expect(detector.isAndroid, isA<bool>());
      expect(detector.isIOS, isA<bool>());
    });
  });

  group('HealthService.isHealthApiAvailable', () {
    test('returns true on iOS without querying Health Connect', () async {
      when(() => mockPlatformDetector.isAndroid).thenReturn(false);
      when(() => mockPlatformDetector.isIOS).thenReturn(true);

      final result = await service.isHealthApiAvailable();

      expect(result, isTrue);
      verifyNever(() => mockHealth.getHealthConnectSdkStatus());
    });

    test('returns true on Android when SDK is available', () async {
      when(() => mockPlatformDetector.isAndroid).thenReturn(true);
      when(() => mockPlatformDetector.isIOS).thenReturn(false);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.sdkAvailable);

      final result = await service.isHealthApiAvailable();

      expect(result, isTrue);
      verify(() => mockHealth.getHealthConnectSdkStatus()).called(1);
    });

    test('returns false on Android when SDK is unavailable', () async {
      when(() => mockPlatformDetector.isAndroid).thenReturn(true);
      when(() => mockPlatformDetector.isIOS).thenReturn(false);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenAnswer((_) async => HealthConnectSdkStatus.sdkUnavailable);

      final result = await service.isHealthApiAvailable();

      expect(result, isFalse);
    });

    test('catches exception and degrades gracefully to false', () async {
      when(() => mockPlatformDetector.isAndroid).thenReturn(true);
      when(() => mockPlatformDetector.isIOS).thenReturn(false);
      when(() => mockHealth.getHealthConnectSdkStatus())
          .thenThrow(Exception('Platform error'));

      final result = await service.isHealthApiAvailable();

      expect(result, isFalse);
    });
  });

  group('HealthService.hasPermissions', () {
    test('checks write permissions on iOS', () async {
      when(() => mockPlatformDetector.isIOS).thenReturn(true);
      when(() => mockPlatformDetector.isAndroid).thenReturn(false);
      when(
        () => mockHealth.hasPermissions(
          any(),
          permissions: const [HealthDataAccess.WRITE, HealthDataAccess.WRITE],
        ),
      ).thenAnswer((_) async => true);

      final result = await service.hasPermissions();

      expect(result, isTrue);
      verify(
        () => mockHealth.hasPermissions(
          const [HealthDataType.HEART_RATE, HealthDataType.WORKOUT],
          permissions: const [HealthDataAccess.WRITE, HealthDataAccess.WRITE],
        ),
      ).called(1);
    });

    test('checks read/write permissions on Android', () async {
      when(() => mockPlatformDetector.isIOS).thenReturn(false);
      when(() => mockPlatformDetector.isAndroid).thenReturn(true);
      when(
        () => mockHealth.hasPermissions(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).thenAnswer((_) async => true);

      final result = await service.hasPermissions();

      expect(result, isTrue);
      verify(
        () => mockHealth.hasPermissions(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).called(1);
    });

    test('returns false when plugin throws', () async {
      when(() => mockPlatformDetector.isIOS).thenReturn(true);
      when(
        () => mockHealth.hasPermissions(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).thenThrow(Exception('Native error'));

      final result = await service.hasPermissions();

      expect(result, isFalse);
    });
  });

  group('HealthService.requestPermissions', () {
    test('requests authorization and verifies on iOS', () async {
      when(() => mockPlatformDetector.isIOS).thenReturn(true);
      when(
        () => mockHealth.requestAuthorization(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockHealth.hasPermissions(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).thenAnswer((_) async => true);

      final result = await service.requestPermissions();

      expect(result, isTrue);
      verify(
        () => mockHealth.requestAuthorization(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).called(1);
      verify(
        () => mockHealth.hasPermissions(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).called(1);
    });

    test('returns false when prompt is denied', () async {
      when(
        () => mockHealth.requestAuthorization(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).thenAnswer((_) async => false);

      final result = await service.requestPermissions();

      expect(result, isFalse);
    });

    test('returns false when request throws', () async {
      when(
        () => mockHealth.requestAuthorization(
          any(),
          permissions: any(named: 'permissions'),
        ),
      ).thenThrow(Exception('Authorization failed'));

      final result = await service.requestPermissions();

      expect(result, isFalse);
    });
  });

  group('HealthService.openSystemSettings', () {
    test('invokes system app settings', () async {
      final result = await service.openSystemSettings();
      expect(result, isTrue);
    });
  });

  group('HealthService.installHealthConnect', () {
    test('does nothing on non-Android devices', () async {
      when(() => mockPlatformDetector.isAndroid).thenReturn(false);

      await service.installHealthConnect();

      expect(launchedUrls, isEmpty);
    });

    test('launches market URI on Android', () async {
      when(() => mockPlatformDetector.isAndroid).thenReturn(true);

      await service.installHealthConnect();

      expect(
        launchedUrls,
        contains('market://details?id=com.google.android.apps.healthdata'),
      );
    });
  });

  group('HealthService history and write methods', () {
    test('fetchHeartRateHistory calls plugin with BPM unit', () async {
      final now = DateTime.now();
      when(
        () => mockHealth.getHealthDataFromTypes(
          types: const [HealthDataType.HEART_RATE],
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          preferredUnits: const {
            HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
          },
        ),
      ).thenAnswer((_) async => []);

      final result = await service.fetchHeartRateHistory(
        start: now.subtract(const Duration(hours: 1)),
        end: now,
      );

      expect(result, isEmpty);
      verify(
        () => mockHealth.getHealthDataFromTypes(
          types: const [HealthDataType.HEART_RATE],
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          preferredUnits: const {
            HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
          },
        ),
      ).called(1);
    });

    test('fetchWorkoutHistory calls plugin for workouts', () async {
      final now = DateTime.now();
      when(
        () => mockHealth.getHealthDataFromTypes(
          types: const [HealthDataType.WORKOUT],
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
        ),
      ).thenAnswer((_) async => []);

      final result = await service.fetchWorkoutHistory(
        start: now.subtract(const Duration(hours: 1)),
        end: now,
      );

      expect(result, isEmpty);
      verify(
        () => mockHealth.getHealthDataFromTypes(
          types: const [HealthDataType.WORKOUT],
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
        ),
      ).called(1);
    });

    test('writeHeartRate writes numeric BPM data point', () async {
      final timestamp = DateTime(2026, 9, 13, 12, 0);
      when(
        () => mockHealth.writeHealthData(
          value: 145.0,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          type: HealthDataType.HEART_RATE,
          startTime: timestamp,
          endTime: timestamp,
          recordingMethod: RecordingMethod.manual,
        ),
      ).thenAnswer((_) async => true);

      final result = await service.writeHeartRate(
        bpm: 145,
        timestamp: timestamp,
      );

      expect(result, isTrue);
    });

    test('writeWorkoutSession writes workout data and avg BPM', () async {
      final session = WorkoutSession(
        id: 1,
        startTime: DateTime(2026, 9, 13, 10, 0),
        endTime: DateTime(2026, 9, 13, 10, 30),
        avgBpm: 140,
        maxBpm: 175,
        bpmSamples: const [135, 140, 145],
        sensorLocationIndex: 1,
        deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
        deviceName: 'Polar H10',
      );

      when(
        () => mockHealth.writeWorkoutData(
          activityType: HealthWorkoutActivityType.OTHER,
          start: session.startTime,
          end: session.endTime!,
          title: 'Polar H10',
          recordingMethod: RecordingMethod.manual,
        ),
      ).thenAnswer((_) async => true);

      when(
        () => mockHealth.writeHealthData(
          value: 140.0,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          type: HealthDataType.HEART_RATE,
          startTime: session.startTime,
          endTime: session.endTime!,
          recordingMethod: RecordingMethod.manual,
        ),
      ).thenAnswer((_) async => true);

      final result = await service.writeWorkoutSession(session: session);

      expect(result, isTrue);
      verify(
        () => mockHealth.writeWorkoutData(
          activityType: HealthWorkoutActivityType.OTHER,
          start: session.startTime,
          end: session.endTime!,
          title: 'Polar H10',
          recordingMethod: RecordingMethod.manual,
        ),
      ).called(1);
      verify(
        () => mockHealth.writeHealthData(
          value: 140.0,
          unit: HealthDataUnit.BEATS_PER_MINUTE,
          type: HealthDataType.HEART_RATE,
          startTime: session.startTime,
          endTime: session.endTime!,
          recordingMethod: RecordingMethod.manual,
        ),
      ).called(1);
    });
  });
}
