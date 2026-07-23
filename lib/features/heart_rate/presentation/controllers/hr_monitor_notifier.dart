import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/infrastructure/services/foreground_service_manager.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/parsers/hr_packet_parser.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_device_profile_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';

part 'hr_monitor_notifier.g.dart';

const Duration _kConnectionTimeout = Duration(seconds: 4);

const Duration _kDiscoverServicesTimeout = Duration(seconds: 8);

final Guid _kHrServiceUuid = Guid('180d');

final Guid _kHrMeasurementCharUuid = Guid('2a37');

final Guid _kBodySensorLocationCharUuid = Guid('2a38');

final Guid _kBatteryServiceUuid = Guid('180f');

final Guid _kBatteryLevelCharacteristicUuid = Guid('2a19');

const Duration _kCheckpointInterval = Duration(seconds: 30);

@riverpod
class HrMonitorNotifier extends _$HrMonitorNotifier
    with WidgetsBindingObserver {
  late final HeartRateMonitorService _monitorService;
  late final ForegroundServiceManager _foregroundServiceManager;

  BluetoothDevice? _device;

  StreamSubscription<List<int>>? _hrNotificationSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _batteryNotificationSubscription;

  final List<int> _collectedBpmSamples = [];
  DateTime? _sessionStartTime;
  String? _sessionDeviceId;
  String? _sessionDeviceName;
  int? _sessionSensorLocationIndex;
  int? _currentBatteryLevel;
  int _currentBpmSum = 0;
  int _currentMaxBpm = 0;
  bool _isDisconnecting = false;
  Timer? _connectTimer;
  Timer? _checkpointTimer;

  /// Isar row id returned by the session's most recent checkpoint write, if
  /// any. Passed back into subsequent checkpoint calls — and into the final
  /// [_saveSessionToDisk] write — so every write after the first UPDATES the
  /// same row instead of INSERTing a new one. Reset to null whenever session
  /// fields are reset (new connection, or after a completed save).
  int? _checkpointSessionId;

  @override
  MonitorState build() {
    _monitorService = ref.read(heartRateMonitorServiceProvider);
    _foregroundServiceManager = ref.read(foregroundServiceManagerProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => _cleanup());
    return const MonitorState.disconnected();
  }

  Future<void> connect(String deviceId, String deviceName) async {
    _connectTimer?.cancel();
    _connectTimer = null;

    if (state is ConnectingMonitorState ||
        state is DiscoveringServicesMonitorState) {
      log.w(
        '[HrMonitorNotifier] connect() ignored — already connecting. '
        'Call disconnect() first to cancel this attempt.',
      );
      return;
    }

    if (state is ConnectedMonitorState) {
      log.w(
        '[HrMonitorNotifier] connect() — device already connected; '
        'disconnecting old device before reconnecting.',
      );
      await _cancelSubscriptions();
      await _safeDisconnectDevice();
      await _foregroundServiceManager.stopService();
      _stopCheckpointTimer();
      _collectedBpmSamples.clear();
      _currentBpmSum = 0;
      _currentMaxBpm = 0;
      _sessionStartTime = null;
      _sessionDeviceId = null;
      _sessionDeviceName = null;
      _sessionSensorLocationIndex = null;
      _currentBatteryLevel = null;
      _checkpointSessionId = null;
      state = const MonitorState.disconnected();
    }

    await _cancelSubscriptions();
    _collectedBpmSamples.clear();
    _currentBpmSum = 0;
    _currentMaxBpm = 0;
    _sessionStartTime = DateTime.now();
    _sessionDeviceId = deviceId;
    _sessionDeviceName = deviceName;
    _sessionSensorLocationIndex = null;
    _currentBatteryLevel = null;
    _checkpointSessionId = null;

    _device = _monitorService.fromId(deviceId);

    log.i('[HrMonitorNotifier] Connecting to "$deviceName" ($deviceId)...');

    state = const MonitorState.connecting();

    try {
      await _foregroundServiceManager.startService();
    } catch (e) {
      log.w(
        '[HrMonitorNotifier] Foreground service startup failed (continuing '
        'BLE connection anyway)',
        error: e,
      );
    }

    _connectTimer = Timer(_kConnectionTimeout, () {
      if (!ref.mounted || state is! ConnectingMonitorState) {
        log.d(
          '[HrMonitorNotifier] Connect timer fired but notifier is inactive '
          'or state is no longer connecting — ignoring stale callback.',
        );
        return;
      }
      log.e(
        '[HrMonitorNotifier] Physical connection timed out after '
        '${_kConnectionTimeout.inSeconds}s.',
      );
      _connectTimer?.cancel();
      _connectTimer = null;
      _foregroundServiceManager.stopService();
      _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'Connection timed out. Make sure the sensor is nearby and powered on.',
      );
    });

    try {
      await _monitorService.connect(_device!, autoConnect: false);
    } catch (e, st) {
      log.e('[HrMonitorNotifier] connect() threw', error: e, stackTrace: st);
      _connectTimer?.cancel();
      _connectTimer = null;
      await _foregroundServiceManager.stopService();
      await _safeDisconnectDevice();
      state = MonitorState.failure(
        message: 'Failed to connect: ${e.toString()}',
      );
      return;
    } finally {
      _connectTimer?.cancel();
      _connectTimer = null;
    }

    if (!ref.mounted || _device == null) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed '
        'while awaiting physical link.',
      );
      return;
    }

    log.i('[HrMonitorNotifier] Physical link established for "$deviceName".');

    _connectionStateSubscription = _monitorService
        .connectionState(_device!)
        .listen(_onDeviceConnectionStateChanged);

    state = const MonitorState.discoveringServices();

    log.i(
      '[HrMonitorNotifier] Discovering GATT services '
      '(timeout: ${_kDiscoverServicesTimeout.inSeconds}s)...',
    );

    List<BluetoothService> services;
    try {
      services = await _monitorService
          .discoverServices(_device!)
          .timeout(_kDiscoverServicesTimeout);
    } on TimeoutException {
      log.e(
        '[HrMonitorNotifier] discoverServices() exceeded '
        '${_kDiscoverServicesTimeout.inSeconds}s deadline — '
        'executing mandatory link-layer disconnect.',
      );
      await _foregroundServiceManager.stopService();
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'Service discovery timed out. Please move closer to the sensor and retry.',
      );
      return;
    } catch (e, st) {
      log.e(
        '[HrMonitorNotifier] discoverServices() threw',
        error: e,
        stackTrace: st,
      );
      await _foregroundServiceManager.stopService();
      await _safeDisconnectDevice();
      state = MonitorState.failure(
        message: 'Service discovery failed: ${e.toString()}',
      );
      return;
    }

    if (!ref.mounted || _device == null) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed '
        'while awaiting GATT discovery.',
      );
      return;
    }

    log.d('[HrMonitorNotifier] Discovered ${services.length} GATT service(s).');

    final BluetoothService? hrService = services
        .where((BluetoothService s) => s.serviceUuid == _kHrServiceUuid)
        .firstOrNull;

    if (hrService == null) {
      log.w(
        '[HrMonitorNotifier] Heart Rate Service (0x180D) not found — '
        'this device is not a standard HR sensor.',
      );
      await _foregroundServiceManager.stopService();
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'Heart Rate Service (0x180D) not found. '
            'Ensure you are connecting to a heart rate sensor.',
      );
      return;
    }

    final BluetoothCharacteristic? hrCharacteristic = hrService.characteristics
        .where(
          (BluetoothCharacteristic c) =>
              c.characteristicUuid == _kHrMeasurementCharUuid,
        )
        .firstOrNull;

    if (hrCharacteristic == null) {
      log.w(
        '[HrMonitorNotifier] HR Measurement Characteristic (0x2A37) not found '
        'on the Heart Rate Service.',
      );
      await _foregroundServiceManager.stopService();
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'HR Measurement Characteristic (0x2A37) not found. '
            'This sensor may use a non-standard firmware profile.',
      );
      return;
    }

    final BodySensorLocation sensorLocation = await _readBodySensorLocation(
      hrService,
    );

    _sessionSensorLocationIndex = sensorLocation.index;

    try {
      await ref
          .read(saveDeviceProfileUseCaseProvider)
          .call(
            macAddress: deviceId,
            name: deviceName,
            sensorLocationIndex: sensorLocation.index,
          );
    } catch (e) {
      log.e('[HrMonitorNotifier] saveDeviceProfile() failed', error: e);
    }

    log.d(
      '[HrMonitorNotifier] Body sensor location: ${sensorLocation.displayName}',
    );

    await _resolveBatteryService(services);

    try {
      await _monitorService.setNotifyValue(hrCharacteristic, true);
    } catch (e, st) {
      log.e(
        '[HrMonitorNotifier] setNotifyValue(true) failed',
        error: e,
        stackTrace: st,
      );
      await _foregroundServiceManager.stopService();
      await _safeDisconnectDevice();
      state = MonitorState.failure(
        message: 'Failed to enable HR notifications: ${e.toString()}',
      );
      return;
    }

    if (!ref.mounted || _device == null) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed '
        'while awaiting GATT notification setup.',
      );
      return;
    }

    log.i(
      '[HrMonitorNotifier] GATT HR notifications active — streaming live data.',
    );

    _hrNotificationSubscription = _monitorService
        .onValueReceived(hrCharacteristic)
        .listen(
          (List<int> rawBytes) {
            if (!ref.mounted) return;

            final HrMeasurement? measurement = HrPacketParser.parseRawBytes(
              rawBytes,
            );
            if (measurement == null) return;

            _collectedBpmSamples.add(measurement.bpm);
            _currentBpmSum += measurement.bpm;
            if (measurement.bpm > _currentMaxBpm) {
              _currentMaxBpm = measurement.bpm;
            }

            final HrMeasurement enrichedMeasurement = measurement.copyWith(
              sensorLocation: sensorLocation,
              batteryLevel: _currentBatteryLevel ?? measurement.batteryLevel,
            );

            state = MonitorState.connected(measurement: enrichedMeasurement);
          },
          onError: (Object error, StackTrace stack) {
            if (!ref.mounted) return;
            log.e(
              '[HrMonitorNotifier] HR notification stream error',
              error: error,
              stackTrace: stack,
            );
            state = MonitorState.failure(
              message: 'Live data stream error: ${error.toString()}',
            );
          },
          onDone: () {
            if (!ref.mounted) return;
            log.w(
              '[HrMonitorNotifier] HR notification stream closed by remote device.',
            );
            if (state is ConnectedMonitorState ||
                state is DiscoveringServicesMonitorState) {
              state = const MonitorState.failure(
                message: 'Heart rate stream was unexpectedly terminated.',
              );
            }
          },
          cancelOnError: false,
        );

    _startCheckpointTimer();
  }

  Future<void> disconnect() async {
    log.i('[HrMonitorNotifier] disconnect() called.');
    _connectTimer?.cancel();
    _connectTimer = null;
    _stopCheckpointTimer();
    _isDisconnecting = true;
    try {
      await _saveSessionToDisk();
      await _cancelSubscriptions();
      await _safeDisconnectDevice();
      await _foregroundServiceManager.stopService();
      state = const MonitorState.disconnected();
    } finally {
      _isDisconnecting = false;
    }
  }

  Future<void> _saveSessionToDisk() async {
    try {
      if (_collectedBpmSamples.isNotEmpty &&
          _sessionStartTime != null &&
          _sessionDeviceId != null &&
          _sessionDeviceName != null) {
        final useCase = ref.read(saveWorkoutSessionUseCaseProvider);

        final samples = List<int>.from(_collectedBpmSamples);
        final startTime = _sessionStartTime!;
        final endTime = DateTime.now();
        final avgBpm = (_currentBpmSum / samples.length).round();

        await useCase.call(
          startTime: startTime,
          endTime: endTime,
          samples: samples,
          sensorLocationIndex:
              _sessionSensorLocationIndex ?? BodySensorLocation.other.index,
          macAddress: _sessionDeviceId!,
          name: _sessionDeviceName!,
          avgBpm: avgBpm,
          maxBpm: _currentMaxBpm,
          existingId: _checkpointSessionId,
        );
      }
    } catch (e) {
      log.e(
        '[HrMonitorNotifier] Failed to persist workout session (data may be lost)',
        error: e,
      );
    } finally {
      _collectedBpmSamples.clear();
      _currentBpmSum = 0;
      _currentMaxBpm = 0;
      _sessionStartTime = null;
      _sessionDeviceId = null;
      _sessionDeviceName = null;
      _sessionSensorLocationIndex = null;
      _checkpointSessionId = null;
    }
  }

  void _startCheckpointTimer() {
    _stopCheckpointTimer();
    _checkpointTimer = Timer.periodic(_kCheckpointInterval, (_) {
      unawaited(_checkpoint());
    });
  }

  void _stopCheckpointTimer() {
    _checkpointTimer?.cancel();
    _checkpointTimer = null;
  }

  Future<void> _checkpoint() async {
    if (state is! ConnectedMonitorState ||
        _collectedBpmSamples.isEmpty ||
        _sessionStartTime == null ||
        _sessionDeviceId == null ||
        _sessionDeviceName == null) {
      return;
    }

    try {
      final savePartial = ref.read(savePartialWorkoutSessionUseCaseProvider);
      final avgBpm = (_currentBpmSum / _collectedBpmSamples.length).round();
      _checkpointSessionId = await savePartial.call(
        startTime: _sessionStartTime!,
        samples: List<int>.of(_collectedBpmSamples),
        sensorLocationIndex:
            _sessionSensorLocationIndex ?? BodySensorLocation.other.index,
        macAddress: _sessionDeviceId!,
        name: _sessionDeviceName!,
        avgBpm: avgBpm,
        maxBpm: _currentMaxBpm,
        existingId: _checkpointSessionId,
      );
      log.d(
        '[HrMonitorNotifier] Checkpoint saved at ${DateTime.now()} '
        'with ${_collectedBpmSamples.length} samples (row id: '
        '$_checkpointSessionId).',
      );
    } catch (e) {
      log.e('[HrMonitorNotifier] Checkpoint failed', error: e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_checkpoint());
    }
  }

  Future<void> retry(String deviceId, String deviceName) async {
    log.i(
      '[HrMonitorNotifier] retry() — tearing down current session '
      'then reconnecting to "$deviceName".',
    );
    await disconnect();
    await connect(deviceId, deviceName);
  }

  Future<BodySensorLocation> _readBodySensorLocation(
    BluetoothService hrService,
  ) async {
    try {
      final BluetoothCharacteristic? locationChar = hrService.characteristics
          .where(
            (BluetoothCharacteristic c) =>
                c.characteristicUuid == _kBodySensorLocationCharUuid,
          )
          .firstOrNull;

      if (locationChar == null) return BodySensorLocation.unknown;

      final List<int> bytes = await _monitorService
          .read(locationChar)
          .timeout(const Duration(seconds: 2));

      if (bytes.isEmpty) return BodySensorLocation.unknown;

      return switch (bytes.first) {
        1 => BodySensorLocation.chest,
        2 => BodySensorLocation.wrist,
        3 => BodySensorLocation.finger,
        4 => BodySensorLocation.hand,
        5 => BodySensorLocation.earLobe,
        6 => BodySensorLocation.foot,
        _ => BodySensorLocation.other,
      };
    } catch (e) {
      log.w(
        '[HrMonitorNotifier] Optional 0x2A38 read failed (ignored)',
        error: e,
      );
      return BodySensorLocation.unknown;
    }
  }

  Future<void> _resolveBatteryService(List<BluetoothService> services) async {
    try {
      final BluetoothService? batteryService = services
          .where((BluetoothService s) => s.serviceUuid == _kBatteryServiceUuid)
          .firstOrNull;

      if (batteryService == null) {
        log.d(
          '[HrMonitorNotifier] Battery Service (0x180F) not found on device.',
        );
        return;
      }

      final BluetoothCharacteristic? batteryChar = batteryService
          .characteristics
          .where(
            (BluetoothCharacteristic c) =>
                c.characteristicUuid == _kBatteryLevelCharacteristicUuid,
          )
          .firstOrNull;

      if (batteryChar == null) {
        log.d(
          '[HrMonitorNotifier] Battery Level Characteristic (0x2A19) not found.',
        );
        return;
      }

      try {
        final List<int> initialBytes = await _monitorService
            .read(batteryChar)
            .timeout(const Duration(seconds: 2));
        if (initialBytes.isNotEmpty) {
          _currentBatteryLevel = initialBytes.first.clamp(0, 100);
          log.d(
            '[HrMonitorNotifier] Initial battery level read: $_currentBatteryLevel%',
          );
        }
      } on TimeoutException {
        log.w(
          '[HrMonitorNotifier] Battery level initial read timed out (2 s) — '
          'will rely on notifications if available.',
        );
      } catch (e) {
        log.e(
          '[HrMonitorNotifier] Battery level initial read failed',
          error: e,
        );
      }

      final bool supportsNotify = batteryChar.properties.notify;
      final bool supportsIndicate = batteryChar.properties.indicate;

      if (supportsNotify || supportsIndicate) {
        await _monitorService.setNotifyValue(batteryChar, true);

        if (!ref.mounted) return;

        _batteryNotificationSubscription = _monitorService
            .onValueReceived(batteryChar)
            .listen(
              (List<int> bytes) {
                if (!ref.mounted) return;
                if (bytes.isNotEmpty) {
                  _updateStateWithBatteryLevel(bytes.first.clamp(0, 100));
                }
              },
              onError: (Object error, StackTrace stack) {
                if (!ref.mounted) return;
                log.e(
                  '[HrMonitorNotifier] Battery notification stream error',
                  error: error,
                );
              },
              cancelOnError: false,
            );
      } else {
        log.d(
          '[HrMonitorNotifier] Battery characteristic found but does not '
          'support notifications/indications. Using initial read value.',
        );
      }
    } catch (e) {
      log.w(
        '[HrMonitorNotifier] Battery service resolution failed (ignored)',
        error: e,
      );
    }
  }

  void _updateStateWithBatteryLevel(int newLevel) {
    if (_currentBatteryLevel == newLevel) return;
    _currentBatteryLevel = newLevel;
    log.d('[HrMonitorNotifier] Battery level updated: $newLevel%');

    if (state is ConnectedMonitorState) {
      final current = state as ConnectedMonitorState;
      state = MonitorState.connected(
        measurement: current.measurement.copyWith(batteryLevel: newLevel),
      );
    }
  }

  Future<void> _onDeviceConnectionStateChanged(
    BluetoothConnectionState connectionState,
  ) async {
    if (!ref.mounted) return;

    log.d(
      '[HrMonitorNotifier] Device connection state → ${connectionState.name}',
    );

    if (_isDisconnecting) {
      log.d(
        '[HrMonitorNotifier] Ignoring connection state event — '
        'disconnect is already in progress.',
      );
      return;
    }

    if (connectionState == BluetoothConnectionState.disconnected) {
      if (state is ConnectedMonitorState ||
          state is ConnectingMonitorState ||
          state is DiscoveringServicesMonitorState) {
        log.w(
          '[HrMonitorNotifier] Unexpected disconnection detected — '
          'surfacing failure state.',
        );
        _hrNotificationSubscription?.cancel();
        _batteryNotificationSubscription?.cancel();
        _hrNotificationSubscription = null;
        _batteryNotificationSubscription = null;
        await _saveSessionToDisk();
        await _foregroundServiceManager.stopService();
        state = const MonitorState.failure(
          message:
              'Connection lost. The sensor may be out of range or powered off.',
        );
      }
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _hrNotificationSubscription?.cancel();
    await _batteryNotificationSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    _hrNotificationSubscription = null;
    _batteryNotificationSubscription = null;
    _connectionStateSubscription = null;
  }

  Future<void> _safeDisconnectDevice() async {
    if (_device == null) return;
    try {
      await _monitorService.disconnect(_device!);
      log.d(
        '[HrMonitorNotifier] Link-layer disconnect completed for '
        '${_device!.remoteId}.',
      );
    } catch (e) {
      log.w(
        '[HrMonitorNotifier] _safeDisconnectDevice() error (logged, not re-thrown)',
        error: e,
      );
    } finally {
      _device = null;
    }
  }

  void _cleanup() {
    log.i(
      '[HrMonitorNotifier] Disposing — releasing all GATT and BLE resources.',
    );
    _connectTimer?.cancel();
    _connectTimer = null;
    _stopCheckpointTimer();
    _hrNotificationSubscription?.cancel();
    _batteryNotificationSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _hrNotificationSubscription = null;
    _batteryNotificationSubscription = null;
    _connectionStateSubscription = null;
    if (_device != null) {
      _monitorService.disconnect(_device!);
      _device = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    _foregroundServiceManager.stopService();
  }
}
