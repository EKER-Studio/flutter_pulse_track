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
import 'package:pulse_track/features/workout/application/workout_providers.dart';

part 'hr_monitor_notifier.g.dart';

const Duration _kConnectionTimeout = Duration(seconds: 4);

const Duration _kDiscoverServicesTimeout = Duration(seconds: 8);

final Guid _kHrServiceUuid = Guid('180d');

final Guid _kHrMeasurementCharUuid = Guid('2a37');

final Guid _kBodySensorLocationCharUuid = Guid('2a38');

final Guid _kBatteryServiceUuid = Guid('180f');

final Guid _kBatteryLevelCharacteristicUuid = Guid('2a19');

const Duration _kCheckpointInterval = Duration(seconds: 30);

/// Manages heart rate monitor connection, GATT discovery, and live telemetry.
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
  bool _checkpointInProgress = false;
  bool _saveInProgress = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  Timer? _connectTimer;
  Timer? _checkpointTimer;
  Timer? _reconnectTimer;

  /// Number of auto-reconnect attempts performed during current disconnection event.
  @visibleForTesting
  int get reconnectAttempts => _reconnectAttempts;

  /// Isar row id returned by the session's most recent checkpoint write, if
  /// any. Passed back into subsequent checkpoint calls — and into the final
  /// [_saveSessionToDisk] write — so every write after the first UPDATES the
  /// same row instead of INSERTing a new one. Reset to null whenever session
  /// fields are reset (new connection, or after a completed save).
  int? _checkpointSessionId;

  /// Initializes dependencies and lifecycle observer.
  ///
  /// Returns the initial [MonitorState.disconnected] state.
  @override
  MonitorState build() {
    _monitorService = ref.read(heartRateMonitorServiceProvider);
    _foregroundServiceManager = ref.read(foregroundServiceManagerProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(_cleanup);
    return const MonitorState.disconnected();
  }

  /// Initiates a BLE connection to peripheral [deviceId] with name [deviceName].
  ///
  /// Establishes link-layer connection, discovers GATT services, subscribes to heart rate
  /// notifications (GATT 0x2A37), and starts periodic session checkpoints.
  /// Returns a [Future] completing when connection setup finishes.
  Future<void> connect(String deviceId, String deviceName) async {
    _connectTimer?.cancel();
    _connectTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;

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

    await _performConnect(deviceId, deviceName, isReconnect: false);
  }

  Future<void> _performConnect(
    String deviceId,
    String deviceName, {
    required bool isReconnect,
  }) async {
    unawaited(_cancelSubscriptions());

    if (!isReconnect) {
      _collectedBpmSamples.clear();
      _currentBpmSum = 0;
      _currentMaxBpm = 0;
      _sessionStartTime = DateTime.now();
      _sessionDeviceId = deviceId;
      _sessionDeviceName = deviceName;
      _sessionSensorLocationIndex = null;
      _currentBatteryLevel = null;
      _checkpointSessionId = null;
    }

    // PII redaction: avoid logging full MAC/deviceId to Crashlytics (C-2).
    final redactedId = deviceId.length > 4
        ? '${deviceId.substring(0, 4)}…'
        : '…';
    log.i(
      '[HrMonitorNotifier] ${isReconnect ? "Reconnecting to" : "Connecting to"} sensor $redactedId...',
    );

    state = const MonitorState.connecting();

    try {
      await _foregroundServiceManager.startService();
    } catch (e) {
      log.w(
        '[HrMonitorNotifier] Foreground service failed to start — proceeding without notification wrapper.',
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
      _safeDisconnectDevice();
      _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage: 'Connection timed out. Make sure the sensor is nearby and powered on.',
      );
    });

    try {
      _device = _monitorService.fromId(deviceId);
      await _monitorService.connect(_device!, autoConnect: false);
    } catch (e, st) {
      log.e('[HrMonitorNotifier] connect() threw', error: e, stackTrace: st);
      _connectTimer?.cancel();
      _connectTimer = null;
      await _safeDisconnectDevice();
      await _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage: 'Failed to connect: $e',
      );
      return;
    } finally {
      _connectTimer?.cancel();
      _connectTimer = null;
    }

    if (!ref.mounted || _device == null || _isDisconnecting) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed or disconnecting '
        'while awaiting physical link.',
      );
      return;
    }

    log.i('[HrMonitorNotifier] Physical link established.');

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
      await _safeDisconnectDevice();
      await _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage: 'Service discovery timed out. Please move closer to the sensor and retry.',
      );
      return;
    } catch (e, st) {
      log.e(
        '[HrMonitorNotifier] discoverServices() threw',
        error: e,
        stackTrace: st,
      );
      await _safeDisconnectDevice();
      await _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage: 'Service discovery failed: $e',
      );
      return;
    }

    if (!ref.mounted || _device == null || _isDisconnecting) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed or disconnecting '
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
      await _safeDisconnectDevice();
      await _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage:
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
      await _safeDisconnectDevice();
      await _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage:
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
      await _safeDisconnectDevice();
      await _handleConnectFailure(
        isReconnect: isReconnect,
        failureMessage: 'Failed to enable HR notifications: $e',
      );
      return;
    }

    if (!ref.mounted || _device == null || _isDisconnecting) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed or disconnecting '
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
              message: 'Live data stream error: $error',
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

    _reconnectAttempts = 0;
    _startCheckpointTimer();
  }

  Future<void> _handleConnectFailure({
    required bool isReconnect,
    required String failureMessage,
  }) async {
    if (!ref.mounted || _isDisconnecting) return;

    if (isReconnect &&
        _reconnectAttempts < _maxReconnectAttempts &&
        _sessionDeviceId != null &&
        _sessionDeviceName != null) {
      _reconnectAttempts++;
      state = const MonitorState.connecting();
      log.i(
        '[HrMonitorNotifier] Auto-reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts '
        'scheduled in 2s.',
      );

      final deviceId = _sessionDeviceId!;
      final deviceName = _sessionDeviceName!;

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 2), () async {
        _reconnectTimer = null;
        if (!ref.mounted || _isDisconnecting) return;
        await _performConnect(deviceId, deviceName, isReconnect: true);
      });
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    await _saveSessionToDisk();
    await _foregroundServiceManager.stopService();
    state = MonitorState.failure(message: failureMessage);
  }

  /// Tears down the active BLE connection, cancels subscriptions, and saves the workout session.
  ///
  /// Returns a [Future] completing when session save and connection teardown finish.
  Future<void> disconnect() async {
    log.i('[HrMonitorNotifier] disconnect() called.');
    _isDisconnecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _connectTimer?.cancel();
    _connectTimer = null;
    _checkpointTimer?.cancel();
    _checkpointTimer = null;

    try {
      await _safeDisconnectDevice();
      await _saveSessionToDisk();
      await _foregroundServiceManager.stopService();
    } catch (e, st) {
      log.e(
        '[HrMonitorNotifier] Error during disconnect()',
        error: e,
        stackTrace: st,
      );
    } finally {
      state = const MonitorState.disconnected();
      _isDisconnecting = false;
      log.i('[HrMonitorNotifier] Disconnection complete.');
    }
  }

  Future<void> _saveSessionToDisk() async {
    if (_saveInProgress) {
      log.d(
        '[HrMonitorNotifier] _saveSessionToDisk() skipped — '
        'a save is already in progress.',
      );
      return;
    }
    _saveInProgress = true;
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
      _saveInProgress = false;
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
    if (_checkpointInProgress) {
      log.d(
        '[HrMonitorNotifier] _checkpoint() skipped — '
        'a checkpoint write is already in progress.',
      );
      return;
    }
    if (state is! ConnectedMonitorState ||
        _collectedBpmSamples.isEmpty ||
        _sessionStartTime == null ||
        _sessionDeviceId == null ||
        _sessionDeviceName == null) {
      return;
    }

    _checkpointInProgress = true;
    try {
      final savePartial = ref.read(savePartialWorkoutSessionUseCaseProvider);
      final avgBpm = (_currentBpmSum / _collectedBpmSamples.length).round();
      final newId = await savePartial.call(
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
      if (newId != null) _checkpointSessionId = newId;
      log.d(
        '[HrMonitorNotifier] Checkpoint saved at ${DateTime.now()} '
        'with ${_collectedBpmSamples.length} samples (row id: '
        '$_checkpointSessionId).',
      );
    } catch (e) {
      log.e('[HrMonitorNotifier] Checkpoint failed', error: e);
    } finally {
      _checkpointInProgress = false;
    }
  }

  /// Handles app lifecycle state changes for [state], forcing an immediate checkpoint on pause/detach.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_checkpoint());
    }
  }

  /// Tears down current connection and re-attempts connecting to [deviceId] with [deviceName].
  ///
  /// Returns a [Future] completing when reconnection attempt finishes.
  Future<void> retry(String deviceId, String deviceName) async {
    log.i('[HrMonitorNotifier] retry() — tearing down current session.');
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
          'attempting auto-reconnect if within limits.',
        );
        unawaited(_cancelSubscriptions());

        await _handleConnectFailure(
          isReconnect: true,
          failureMessage:
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
      log.d('[HrMonitorNotifier] Link-layer disconnect completed.');
    } catch (e) {
      log.w(
        '[HrMonitorNotifier] _safeDisconnectDevice() error (logged, not re-thrown)',
        error: e,
      );
    } finally {
      _device = null;
    }
  }

  Future<void> _cleanup() async {
    log.i(
      '[HrMonitorNotifier] Disposing — releasing all GATT and BLE resources.',
    );

    // 1. Force-save any unsaved BPM samples before releasing resources.
    if (_collectedBpmSamples.isNotEmpty && !_saveInProgress) {
      try {
        await _saveSessionToDisk();
      } catch (e, st) {
        log.e(
          '[HrMonitorNotifier] _cleanup: Failed to force-save session to disk',
          error: e,
          stackTrace: st,
        );
      }
    }

    // 2. Cancel all timers first (they may trigger state changes).
    _connectTimer?.cancel();
    _connectTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _stopCheckpointTimer();

    // 3. Safely disconnect BLE device — await the future to ensure OS releases
    //    hardware resources before we null out the reference.
    final deviceToDisconnect = _device;
    if (deviceToDisconnect != null) {
      try {
        await _monitorService.disconnect(deviceToDisconnect);
        log.d(
          '[HrMonitorNotifier] _cleanup: Successfully disconnected from device.',
        );
      } catch (e, st) {
        log.w(
          '[HrMonitorNotifier] _cleanup disconnect error',
          error: e,
          stackTrace: st,
        );
      }
    }
    _device = null;

    // 4. Cancel subscriptions sequentially — each cancel must complete before
    //    the next subscription is nulled to avoid race conditions.
    await _hrNotificationSubscription?.cancel();
    _hrNotificationSubscription = null;
    await _batteryNotificationSubscription?.cancel();
    _batteryNotificationSubscription = null;
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    // 5. Remove lifecycle observer and stop foreground service.
    WidgetsBinding.instance.removeObserver(this);

    try {
      await _foregroundServiceManager.stopService();
    } catch (e, st) {
      log.w(
        '[HrMonitorNotifier] _cleanup stopService error',
        error: e,
        stackTrace: st,
      );
    }
  }
}
