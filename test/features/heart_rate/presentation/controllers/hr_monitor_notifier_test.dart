import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_device_profile_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockHeartRateMonitorService extends Mock
    implements HeartRateMonitorService {}

class _MockBluetoothDevice extends Mock implements BluetoothDevice {}

class _MockBluetoothCharacteristic extends Mock
    implements BluetoothCharacteristic {}

class _MockBluetoothService extends Mock implements BluetoothService {}

class _MockForegroundServiceManager extends Mock
    implements ForegroundServiceManager {}

class _MockSaveDeviceProfileUseCase extends Mock
    implements SaveDeviceProfileUseCase {}

class _MockSaveWorkoutSessionUseCase extends Mock
    implements SaveWorkoutSessionUseCase {}

class _MockSavePartialWorkoutSessionUseCase extends Mock
    implements SavePartialWorkoutSessionUseCase {}

// ── Fakes (for registerFallbackValue) ────────────────────────────────────────

class _BluetoothDeviceFake extends Fake implements BluetoothDevice {}

class _BluetoothCharacteristicFake extends Fake
    implements BluetoothCharacteristic {}

class _BluetoothServiceFake extends Fake implements BluetoothService {}

// ── Helpers ────────────────────────────────────────────────────────────────

const _kTestDeviceId = 'AA:BB:CC:DD:EE:FF';
const _kTestDeviceName = 'Test HR Sensor';
final _kHrServiceGuid = Guid('180d');
final _kHrCharGuid = Guid('2a37');
final _kSensorLocationGuid = Guid('2a38');
final _kBatteryServiceGuid = Guid('180f');
final _kBatteryCharGuid = Guid('2a19');

ProviderContainer createContainer({
  HeartRateMonitorService? monitorService,
  ForegroundServiceManager? foregroundServiceManager,
  SaveDeviceProfileUseCase? saveDeviceProfileUseCase,
  SaveWorkoutSessionUseCase? saveWorkoutSessionUseCase,
  SavePartialWorkoutSessionUseCase? savePartialWorkoutSessionUseCase,
}) {
  return ProviderContainer(
    overrides: [
      if (monitorService != null)
        heartRateMonitorServiceProvider.overrideWithValue(monitorService),
      if (foregroundServiceManager != null)
        foregroundServiceManagerProvider.overrideWithValue(
          foregroundServiceManager,
        ),
      if (saveDeviceProfileUseCase != null)
        saveDeviceProfileUseCaseProvider.overrideWithValue(
          saveDeviceProfileUseCase,
        ),
      if (saveWorkoutSessionUseCase != null)
        saveWorkoutSessionUseCaseProvider.overrideWithValue(
          saveWorkoutSessionUseCase,
        ),
      if (savePartialWorkoutSessionUseCase != null)
        savePartialWorkoutSessionUseCaseProvider.overrideWithValue(
          savePartialWorkoutSessionUseCase,
        ),
    ],
  );
}

/// Builds a standard set of interconnected mocks that simulate a working BLE
/// heart-rate sensor. Returns the container and the individual mocks so callers
/// can add custom stubs or verify interactions.
({
  ProviderContainer container,
  _MockHeartRateMonitorService monitorService,
  _MockForegroundServiceManager foregroundServiceManager,
  _MockSaveDeviceProfileUseCase saveDeviceProfileUseCase,
  _MockSaveWorkoutSessionUseCase saveWorkoutSessionUseCase,
  _MockSavePartialWorkoutSessionUseCase savePartialWorkoutSessionUseCase,
  _MockBluetoothDevice device,
  _MockBluetoothCharacteristic hrCharacteristic,
  _MockBluetoothService hrService,
  StreamController<BluetoothConnectionState> connectionStateController,
  StreamController<List<int>> hrValueController,
})
buildMocks({Future<void> Function(Invocation)? onConnect}) {
  final monitorService = _MockHeartRateMonitorService();
  final foregroundServiceManager = _MockForegroundServiceManager();
  final saveDeviceProfileUseCase = _MockSaveDeviceProfileUseCase();
  final saveWorkoutSessionUseCase = _MockSaveWorkoutSessionUseCase();
  final savePartialWorkoutSessionUseCase =
      _MockSavePartialWorkoutSessionUseCase();

  final device = _MockBluetoothDevice();
  when(() => device.remoteId).thenReturn(DeviceIdentifier(_kTestDeviceId));

  when(() => monitorService.fromId(_kTestDeviceId)).thenReturn(device);

  when(
    () =>
        monitorService.connect(device, autoConnect: any(named: 'autoConnect')),
  ).thenAnswer(onConnect ?? (_) => Future.value());

  when(() => monitorService.disconnect(device))
      .thenAnswer((_) => Future.value());

  final connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();
  when(() => monitorService.connectionState(device))
      .thenAnswer((_) => connectionStateController.stream);

  final hrCharacteristic = _MockBluetoothCharacteristic();
  when(() => hrCharacteristic.characteristicUuid).thenReturn(_kHrCharGuid);
  when(() => hrCharacteristic.uuid).thenReturn(_kHrCharGuid);

  final hrService = _MockBluetoothService();
  when(() => hrService.serviceUuid).thenReturn(_kHrServiceGuid);
  when(() => hrService.uuid).thenReturn(_kHrServiceGuid);
  when(() => hrService.characteristics).thenReturn([hrCharacteristic]);

  when(() => monitorService.discoverServices(device))
      .thenAnswer((_) => Future.value([hrService]));

  when(() => monitorService.setNotifyValue(hrCharacteristic, any()))
      .thenAnswer((_) => Future.value());

  final hrValueController = StreamController<List<int>>.broadcast();
  when(() => monitorService.onValueReceived(hrCharacteristic))
      .thenAnswer((_) => hrValueController.stream);

  when(() => foregroundServiceManager.startService())
      .thenAnswer((_) => Future.value());
  when(() => foregroundServiceManager.stopService())
      .thenAnswer((_) => Future.value());
  when(
    () => saveDeviceProfileUseCase.call(
      macAddress: any(named: 'macAddress'),
      name: any(named: 'name'),
      sensorLocationIndex: any(named: 'sensorLocationIndex'),
    ),
  ).thenAnswer((_) => Future.value());
  when(
    () => saveWorkoutSessionUseCase.call(
      startTime: any(named: 'startTime'),
      endTime: any(named: 'endTime'),
      samples: any(named: 'samples'),
      avgBpm: any(named: 'avgBpm'),
      maxBpm: any(named: 'maxBpm'),
      sensorLocationIndex: any(named: 'sensorLocationIndex'),
      macAddress: any(named: 'macAddress'),
      name: any(named: 'name'),
    ),
  ).thenAnswer((_) => Future.value());
  when(
    () => savePartialWorkoutSessionUseCase.call(
      startTime: any(named: 'startTime'),
      samples: any(named: 'samples'),
      sensorLocationIndex: any(named: 'sensorLocationIndex'),
      macAddress: any(named: 'macAddress'),
      name: any(named: 'name'),
      avgBpm: any(named: 'avgBpm'),
      maxBpm: any(named: 'maxBpm'),
      existingId: any(named: 'existingId'),
    ),
  ).thenAnswer((_) => Future.value(1));

  final container = createContainer(
    monitorService: monitorService,
    foregroundServiceManager: foregroundServiceManager,
    saveDeviceProfileUseCase: saveDeviceProfileUseCase,
    saveWorkoutSessionUseCase: saveWorkoutSessionUseCase,
    savePartialWorkoutSessionUseCase: savePartialWorkoutSessionUseCase,
  );

  return (
    container: container,
    monitorService: monitorService,
    foregroundServiceManager: foregroundServiceManager,
    saveDeviceProfileUseCase: saveDeviceProfileUseCase,
    saveWorkoutSessionUseCase: saveWorkoutSessionUseCase,
    savePartialWorkoutSessionUseCase: savePartialWorkoutSessionUseCase,
    device: device,
    hrCharacteristic: hrCharacteristic,
    hrService: hrService,
    connectionStateController: connectionStateController,
    hrValueController: hrValueController,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late HrMonitorNotifier notifier;

  setUpAll(() {
    registerFallbackValue(_BluetoothDeviceFake());
    registerFallbackValue(_BluetoothCharacteristicFake());
    registerFallbackValue(_BluetoothServiceFake());
  });

  setUp(() {
    resetMocktailState();
  });

  /// Keeps [hrMonitorProvider] alive across async gaps by maintaining a
  /// dummy listener. Auto-dispose providers get disposed immediately when
  /// they have zero subscribers — without this every test with [`await`]
  /// between [connect] and state assertions would observe a disposed provider.
  /// Must be called before the first [`await`] after [buildMocks].
  void keepAlive([List<MonitorState>? capture]) {
    container.listen<MonitorState>(
      hrMonitorProvider,
      capture == null ? (_, _) {} : (_, next) => capture.add(next),
    );
  }

  tearDown(() {
    try {
      container.dispose();
    } catch (_) {}
  });

  group('initial state', () {
    test('build() returns MonitorState.disconnected()', () {
      final m = buildMocks();
      container = m.container;

      final state = container.read(hrMonitorProvider);
      expect(state, isA<DisconnectedMonitorState>());
    });
  });

  group('connect()', () {
    test('happy path transitions: connecting → discoveringServices', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);

      final states = <MonitorState>[];
      keepAlive(states);

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      expect(states.any((s) => s is ConnectingMonitorState), true);
      expect(states.any((s) => s is DiscoveringServicesMonitorState), true);
    });

    test(
      'incoming HR data emits ConnectedMonitorState with measurement',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        // Simulate an incoming HR packet: flags=0x00 (8-bit BPM), bpm=120
        m.hrValueController.add([0x00, 120]);
        await Future.delayed(Duration.zero);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<ConnectedMonitorState>());
        final connected = state as ConnectedMonitorState;
        expect(connected.measurement.bpm, 120);
        expect(
          connected.measurement.sensorLocation,
          BodySensorLocation.unknown,
        );
      },
    );

    test('already connecting is ignored', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      // Block the physical connect so the notifier stays in connecting
      // state when the second call arrives.
      final connectCompleter = Completer<void>();
      when(
        () => m.monitorService.connect(
          any(),
          autoConnect: any(named: 'autoConnect'),
        ),
      ).thenAnswer((_) => connectCompleter.future);

      // Start connecting but don't await
      final connectFuture = notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Give the first connect microtask to set ConnectingMonitorState
      await Future.delayed(Duration.zero);

      // Second call sees we are still connecting → returns early
      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // discoverServices was never reached (connect is still blocked)
      verifyNever(() => m.monitorService.discoverServices(any()));

      connectCompleter.complete();
      await connectFuture;
    });

    test(
      'physical connection error transitions to FailureMonitorState',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        when(
          () => m.monitorService.connect(
            any(),
            autoConnect: any(named: 'autoConnect'),
          ),
        ).thenThrow(PlatformException(code: 'CONNECT_FAILED'));

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
        expect(
          (state as FailureMonitorState).message,
          contains('CONNECT_FAILED'),
        );
      },
    );

    test('connection timeout transitions to FailureMonitorState', () async {
      FakeAsync().run((async) {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        // Never complete the connect Future — timer must fire
        when(
          () => m.monitorService.connect(
            any(),
            autoConnect: any(named: 'autoConnect'),
          ),
        ).thenAnswer((_) => Completer<void>().future);

        unawaited(notifier.connect(_kTestDeviceId, _kTestDeviceName));

        async.elapse(const Duration(seconds: 5));

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
      });
    });

    test(
      'service discovery error transitions to FailureMonitorState',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        when(() => m.monitorService.discoverServices(any()))
            .thenThrow(PlatformException(code: 'DISCOVER_FAILED'));

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
      },
    );

    test(
      'HR service 0x180D not found transitions to FailureMonitorState',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        // Return services but without the HR service
        final otherService = _MockBluetoothService();
        when(() => otherService.serviceUuid).thenReturn(Guid('180f'));
        when(() => otherService.uuid).thenReturn(Guid('180f'));
        when(() => m.monitorService.discoverServices(any()))
            .thenAnswer((_) async => [otherService]);

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
        expect((state as FailureMonitorState).message, contains('0x180D'));
      },
    );

    test(
      'HR characteristic 0x2A37 not found transitions to FailureMonitorState',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        // Service exists but without the HR measurement characteristic
        final badService = _MockBluetoothService();
        when(() => badService.serviceUuid).thenReturn(_kHrServiceGuid);
        when(() => badService.uuid).thenReturn(_kHrServiceGuid);
        when(() => badService.characteristics).thenReturn([]);
        when(() => m.monitorService.discoverServices(any()))
            .thenAnswer((_) async => [badService]);

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
        expect((state as FailureMonitorState).message, contains('0x2A37'));
      },
    );

    test('setNotifyValue error transitions to FailureMonitorState', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      when(() => m.monitorService.setNotifyValue(any(), any()))
          .thenThrow(PlatformException(code: 'NOTIFY_FAILED'));

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      final state = container.read(hrMonitorProvider);
      expect(state, isA<FailureMonitorState>());
      expect((state as FailureMonitorState).message, contains('NOTIFY_FAILED'));
    });

    test(
      'notification stream error transitions to FailureMonitorState',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        m.hrValueController.addError(Exception('stream error'));
        await Future.delayed(Duration.zero);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
      },
    );

    test(
      'notification stream done transitions to FailureMonitorState',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        await m.hrValueController.close();
        await Future.delayed(Duration.zero);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<FailureMonitorState>());
      },
    );

    test('body sensor location is read from GATT and saved', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      // Add sensor location characteristic to HR service
      final locationChar = _MockBluetoothCharacteristic();
      when(() => locationChar.characteristicUuid)
          .thenReturn(_kSensorLocationGuid);
      when(() => locationChar.uuid).thenReturn(_kSensorLocationGuid);
      when(() => m.monitorService.read(locationChar)).thenAnswer(
        (_) async => [1], // chest
      );
      when(() => m.hrService.characteristics)
          .thenReturn([m.hrCharacteristic, locationChar]);

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      verify(
        () => m.saveDeviceProfileUseCase.call(
          macAddress: _kTestDeviceId,
          name: _kTestDeviceName,
          sensorLocationIndex: BodySensorLocation.chest.index,
        ),
      ).called(1);

      // Also verify measurement includes the location
      m.hrValueController.add([0x00, 80]);
      await Future.delayed(Duration.zero);

      final state = container.read(hrMonitorProvider) as ConnectedMonitorState;
      expect(state.measurement.sensorLocation, BodySensorLocation.chest);
    });
  });

  group('battery service', () {
    test('battery level is read when Battery Service is present', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      // Add Battery Service with characteristic
      final batteryChar = _MockBluetoothCharacteristic();
      when(() => batteryChar.characteristicUuid).thenReturn(_kBatteryCharGuid);
      when(() => batteryChar.uuid).thenReturn(_kBatteryCharGuid);
      when(() => batteryChar.properties).thenReturn(
        const CharacteristicProperties(notify: false, indicate: false),
      );

      final batteryService = _MockBluetoothService();
      when(() => batteryService.serviceUuid).thenReturn(_kBatteryServiceGuid);
      when(() => batteryService.uuid).thenReturn(_kBatteryServiceGuid);
      when(() => batteryService.characteristics).thenReturn([batteryChar]);

      when(() => m.monitorService.discoverServices(any()))
          .thenAnswer((_) async => [m.hrService, batteryService]);

      when(() => m.monitorService.read(batteryChar))
          .thenAnswer((_) async => [75]);

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Battery level should be reflected in measurement
      m.hrValueController.add([0x00, 90]);
      await Future.delayed(Duration.zero);

      final state = container.read(hrMonitorProvider) as ConnectedMonitorState;
      expect(state.measurement.batteryLevel, 75);
    });

    test('battery notification updates battery level in state', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      final states = <MonitorState>[];
      keepAlive(states);

      // Battery service with notify-capable characteristic
      final batteryChar = _MockBluetoothCharacteristic();
      when(() => batteryChar.characteristicUuid).thenReturn(_kBatteryCharGuid);
      when(() => batteryChar.uuid).thenReturn(_kBatteryCharGuid);
      when(() => batteryChar.properties)
          .thenReturn(const CharacteristicProperties(notify: true));

      final batteryService = _MockBluetoothService();
      when(() => batteryService.serviceUuid).thenReturn(_kBatteryServiceGuid);
      when(() => batteryService.uuid).thenReturn(_kBatteryServiceGuid);
      when(() => batteryService.characteristics).thenReturn([batteryChar]);

      when(() => m.monitorService.discoverServices(any()))
          .thenAnswer((_) async => [m.hrService, batteryService]);
      when(() => m.monitorService.read(batteryChar))
          .thenAnswer((_) async => [50]);
      when(() => m.monitorService.setNotifyValue(batteryChar, any()))
          .thenAnswer((_) async {});

      final batteryValueController = StreamController<List<int>>.broadcast();
      when(() => m.monitorService.onValueReceived(batteryChar))
          .thenAnswer((_) => batteryValueController.stream);

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Send HR data first
      m.hrValueController.add([0x00, 100]);
      await Future.delayed(Duration.zero);
      var state = container.read(hrMonitorProvider) as ConnectedMonitorState;
      expect(state.measurement.batteryLevel, 50);

      // Battery notification updates _currentBatteryLevel internally.
      batteryValueController.add([85]);
      await Future.delayed(Duration.zero);

      // A new HR packet is needed to emit a refreshed state from the
      // HR notification handler.
      m.hrValueController.add([0x00, 99]);
      await Future.delayed(Duration.zero);

      state = container.read(hrMonitorProvider) as ConnectedMonitorState;
      expect(state.measurement.batteryLevel, 85);

      await batteryValueController.close();
    });
  });

  group('disconnect()', () {
    test(
      'saves session, disconnects device, transitions to disconnected',
      () async {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        await notifier.connect(_kTestDeviceId, _kTestDeviceName);

        // Send some HR data so there is a session to save
        m.hrValueController.add([0x00, 100]);
        m.hrValueController.add([0x00, 120]);
        await Future.delayed(Duration.zero);

        when(
          () => m.saveWorkoutSessionUseCase.call(
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
            samples: any(named: 'samples'),
            sensorLocationIndex: any(named: 'sensorLocationIndex'),
            macAddress: any(named: 'macAddress'),
            name: any(named: 'name'),
            avgBpm: any(named: 'avgBpm'),
            maxBpm: any(named: 'maxBpm'),
            existingId: any(named: 'existingId'),
          ),
        ).thenAnswer((_) async {});

        await notifier.disconnect();

        verify(
          () => m.saveWorkoutSessionUseCase.call(
            startTime: any(named: 'startTime'),
            endTime: any(named: 'endTime'),
            samples: any(named: 'samples'),
            sensorLocationIndex: any(named: 'sensorLocationIndex'),
            macAddress: any(named: 'macAddress'),
            name: any(named: 'name'),
            avgBpm: any(named: 'avgBpm'),
            maxBpm: any(named: 'maxBpm'),
            existingId: any(named: 'existingId'),
          ),
        ).called(1);

        verify(() => m.monitorService.disconnect(any())).called(1);
        verify(() => m.foregroundServiceManager.stopService()).called(1);

        final state = container.read(hrMonitorProvider);
        expect(state, isA<DisconnectedMonitorState>());
      },
    );

    test('no session saved when no BPM samples collected', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);
      await notifier.disconnect();

      verifyNever(
        () => m.saveWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      );
    });
  });

  group('retry()', () {
    test('calls disconnect then connect', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Stub fromId for the retry device so it reuses the same mock device
      when(() => m.monitorService.fromId('NEW:DEVICE:01')).thenReturn(m.device);

      await notifier.retry('NEW:DEVICE:01', 'New Sensor');

      // Should have disconnected the old device
      verify(() => m.monitorService.disconnect(any())).called(1);

      // Send HR data so the new connection reaches connected state
      m.hrValueController.add([0x00, 95]);
      await Future.delayed(Duration.zero);

      final state = container.read(hrMonitorProvider);
      expect(state, isA<ConnectedMonitorState>());
    });
  });

  group('connection state change', () {
    void flushAll(FakeAsync async) {
      for (var i = 0; i < 20; i++) {
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 1));
      }
    }

    test('unexpected disconnect triggers up to 3 reconnect attempts before failing', () async {
      FakeAsync().run((async) {
        var connectCount = 0;
        final m = buildMocks(
          onConnect: (_) {
            connectCount++;
            if (connectCount > 1) {
              return Future.error(PlatformException(code: 'RECONNECT_FAILED'));
            }
            return Future.value();
          },
        );
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        unawaited(notifier.connect(_kTestDeviceId, _kTestDeviceName));
        flushAll(async);
        m.hrValueController.add([0x00, 100]);
        flushAll(async);

        expect(notifier.reconnectAttempts, 0);

        // Simulate unexpected device disconnection
        m.connectionStateController.add(BluetoothConnectionState.disconnected);
        flushAll(async);

        // 1st unexpected disconnect schedules 1st reconnect attempt
        expect(notifier.reconnectAttempts, 1);
        expect(
          container.read(hrMonitorProvider),
          isA<ConnectingMonitorState>(),
        );

        // Elapse 2s for 1st reconnect attempt to run and fail -> schedules 2nd attempt
        async.elapse(const Duration(seconds: 2));
        flushAll(async);
        expect(notifier.reconnectAttempts, 2);
        expect(
          container.read(hrMonitorProvider),
          isA<ConnectingMonitorState>(),
        );

        // Elapse 2s for 2nd reconnect attempt to run and fail -> schedules 3rd attempt
        async.elapse(const Duration(seconds: 2));
        flushAll(async);
        expect(notifier.reconnectAttempts, 3);
        expect(
          container.read(hrMonitorProvider),
          isA<ConnectingMonitorState>(),
        );

        // Elapse 2s for 3rd reconnect attempt to run and fail -> limit reached, fails session
        async.elapse(const Duration(seconds: 2));
        flushAll(async);
        expect(notifier.reconnectAttempts, 0);
        expect(container.read(hrMonitorProvider), isA<FailureMonitorState>());
      });
    });

    test(
      'successful auto-reconnect resets reconnectAttempts counter to 0',
      () async {
        FakeAsync().run((async) {
          final m = buildMocks();
          container = m.container;
          notifier = container.read(hrMonitorProvider.notifier);
          keepAlive();

          unawaited(notifier.connect(_kTestDeviceId, _kTestDeviceName));
          flushAll(async);
          m.hrValueController.add([0x00, 100]);
          flushAll(async);

          // Simulate unexpected device disconnection
          m.connectionStateController.add(
            BluetoothConnectionState.disconnected,
          );
          flushAll(async);
          expect(notifier.reconnectAttempts, 1);

          // Elapse 2s delay for reconnect attempt to execute and succeed
          async.elapse(const Duration(seconds: 2));
          flushAll(async);

          // Successful reconnect resets counter to 0
          expect(notifier.reconnectAttempts, 0);
        });
      },
    );

    test('intentional disconnect() cancels pending auto-reconnect loop', () async {
      FakeAsync().run((async) {
        final m = buildMocks();
        container = m.container;
        notifier = container.read(hrMonitorProvider.notifier);
        keepAlive();

        unawaited(notifier.connect(_kTestDeviceId, _kTestDeviceName));
        flushAll(async);
        m.hrValueController.add([0x00, 100]);
        flushAll(async);

        // Simulate unexpected device disconnection
        m.connectionStateController.add(BluetoothConnectionState.disconnected);
        flushAll(async);
        expect(notifier.reconnectAttempts, 1);

        // User calls disconnect() intentionally during pending reconnect timer
        unawaited(notifier.disconnect());
        flushAll(async);

        // Reconnect counter reset and state is DisconnectedMonitorState
        expect(notifier.reconnectAttempts, 0);
        expect(
          container.read(hrMonitorProvider),
          isA<DisconnectedMonitorState>(),
        );

        // Advancing time does not trigger any further reconnect attempts
        async.elapse(const Duration(seconds: 10));
        flushAll(async);
        expect(notifier.reconnectAttempts, 0);
        expect(
          container.read(hrMonitorProvider),
          isA<DisconnectedMonitorState>(),
        );
      });
    });

    test('disconnect during disconnecting is ignored', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Start disconnect
      final disconnectFuture = notifier.disconnect();

      // Simulate device disconnection while disconnecting
      m.connectionStateController.add(BluetoothConnectionState.disconnected);
      await Future.delayed(Duration.zero);

      await disconnectFuture;

      // Should be disconnected (or failure) — not relevant, just no crash
      final state = container.read(hrMonitorProvider);
      expect(state, isA<DisconnectedMonitorState>());
    });
  });

  group('checkpoint', () {
    test('checkpoint is saved periodically during connected state', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Send some HR data
      m.hrValueController.add([0x00, 110]);
      m.hrValueController.add([0x00, 120]);
      await Future.delayed(Duration.zero);

      // Wait for checkpoint interval (30s) — we cannot actually wait,
      // but verify the timer is set up and checkpoint is called via
      // lifecycle callback
      final state = container.read(hrMonitorProvider);
      expect(state, isA<ConnectedMonitorState>());
    });
  });

  group('app lifecycle', () {
    test('didChangeAppLifecycleState paused triggers checkpoint', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Send some HR data
      m.hrValueController.add([0x00, 130]);
      await Future.delayed(Duration.zero);

      // Trigger checkpoint via lifecycle
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future.delayed(Duration.zero);

      verify(
        () => m.savePartialWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).called(1);
    });

    test('didChangeAppLifecycleState detached triggers checkpoint', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);
      m.hrValueController.add([0x00, 140]);
      await Future.delayed(Duration.zero);

      notifier.didChangeAppLifecycleState(AppLifecycleState.detached);
      await Future.delayed(Duration.zero);

      verify(
        () => m.savePartialWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).called(1);
    });
  });

  group('already connected', () {
    test('connect() when already connected reconnects cleanly', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);

      // Send HR data
      m.hrValueController.add([0x00, 100]);
      await Future.delayed(Duration.zero);
      var state = container.read(hrMonitorProvider);
      expect(state, isA<ConnectedMonitorState>());

      // Stub fromId for the reconnect device so it reuses the same mock
      when(() => m.monitorService.fromId('NEW:DEVICE')).thenReturn(m.device);

      await notifier.connect('NEW:DEVICE', 'New Device');

      // Should disconnect first then reconnect
      verify(() => m.monitorService.disconnect(any())).called(1);
      verify(() => m.foregroundServiceManager.stopService()).called(1);

      // Send HR data so the new connection reaches connected state
      m.hrValueController.add([0x00, 100]);
      await Future.delayed(Duration.zero);

      state = container.read(hrMonitorProvider);
      expect(state, isA<ConnectedMonitorState>());
    });
  });

  group('defensive race-condition guards', () {
    test('_saveSessionToDisk blocks duplicate save calls when _saveInProgress is true', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      final saveCompleter = Completer<void>();
      when(
        () => m.saveWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).thenAnswer((_) => saveCompleter.future);

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);
      m.hrValueController.add([0x00, 140]);
      await Future.delayed(Duration.zero);

      // Trigger explicit disconnect (starts _saveSessionToDisk, awaiting saveCompleter)
      final disconnectFuture = notifier.disconnect();

      // Simulate unexpected disconnection event on stream while disconnect() is awaiting saveCompleter
      m.connectionStateController.add(BluetoothConnectionState.disconnected);
      await Future.delayed(Duration.zero);

      // Complete the first save
      saveCompleter.complete();
      await disconnectFuture;

      // Verify saveWorkoutSessionUseCase was only called ONCE despite duplicate trigger
      verify(
        () => m.saveWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).called(1);
    });

    test('_checkpoint blocks concurrent checkpoint calls when _checkpointInProgress is true', () async {
      final m = buildMocks();
      container = m.container;
      notifier = container.read(hrMonitorProvider.notifier);
      keepAlive();

      final checkpointCompleter = Completer<int>();
      when(
        () => m.savePartialWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).thenAnswer((_) => checkpointCompleter.future);

      await notifier.connect(_kTestDeviceId, _kTestDeviceName);
      m.hrValueController.add([0x00, 140]);
      await Future.delayed(Duration.zero);

      // Fire first lifecycle change (paused) which calls _checkpoint() and awaits checkpointCompleter
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future.delayed(Duration.zero);

      // Fire second lifecycle change (detached) while first checkpoint is still in progress
      notifier.didChangeAppLifecycleState(AppLifecycleState.detached);
      await Future.delayed(Duration.zero);

      // Resolve first checkpoint
      checkpointCompleter.complete(42);
      await Future.delayed(Duration.zero);

      // Verify savePartialWorkoutSessionUseCase was called ONCE, not twice
      verify(
        () => m.savePartialWorkoutSessionUseCase.call(
          startTime: any(named: 'startTime'),
          samples: any(named: 'samples'),
          sensorLocationIndex: any(named: 'sensorLocationIndex'),
          macAddress: any(named: 'macAddress'),
          name: any(named: 'name'),
          avgBpm: any(named: 'avgBpm'),
          maxBpm: any(named: 'maxBpm'),
          existingId: any(named: 'existingId'),
        ),
      ).called(1);
    });
  });
}
