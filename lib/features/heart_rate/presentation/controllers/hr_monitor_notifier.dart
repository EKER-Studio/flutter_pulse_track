import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/application/service_providers.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/domain/parsers/hr_packet_parser.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';

import 'gatt_profile_resolver.dart';
import 'workout_session_recorder.dart';

part 'hr_monitor_notifier.g.dart';

const Duration _kConnectionTimeout = Duration(seconds: 4);
const Duration _kDiscoverServicesTimeout = Duration(seconds: 8);

final Guid _kHrServiceUuid = Guid('180d');
final Guid _kHrMeasurementCharUuid = Guid('2a37');

/// Manages heart rate monitor connection, GATT discovery, and live telemetry.
@riverpod
class HrMonitorNotifier extends _$HrMonitorNotifier
    with WidgetsBindingObserver {
  late final HeartRateMonitorService _monitorService;
  late final ForegroundServiceManager _foregroundServiceManager;
  late final WorkoutSessionRecorder _recorder;
  late final GattProfileResolver _gattResolver;

  BluetoothDevice? _device;

  StreamSubscription<List<int>>? _hrNotificationSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _batteryNotificationSubscription;

  String? _sessionDeviceId;
  String? _sessionDeviceName;
  BodySensorLocation _sensorLocation = BodySensorLocation.unknown;
  int? _currentBatteryLevel;
  bool _isDisconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  Timer? _connectTimer;
  Timer? _reconnectTimer;

  /// Number of auto-reconnect attempts performed during current disconnection event.
  @visibleForTesting
  int get reconnectAttempts => _reconnectAttempts;

  @override
  MonitorState build() {
    _monitorService = ref.read(heartRateMonitorServiceProvider);
    _foregroundServiceManager = ref.read(foregroundServiceManagerProvider);
    _recorder = WorkoutSessionRecorder(
      saveWorkoutSessionUseCase: ref.read(saveWorkoutSessionUseCaseProvider),
      savePartialWorkoutSessionUseCase: ref.read(
        savePartialWorkoutSessionUseCaseProvider,
      ),
    );
    _gattResolver = GattProfileResolver(_monitorService);

    WidgetsBinding.instance.addObserver(this);
    // Fire-and-forget is intentional: onDispose cannot await, so _cleanup
    // cancels timers and subscriptions synchronously first; the async
    // disconnects complete best-effort in the background.
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
      _recorder.stopCheckpointTimer();
      _recorder.reset();
      _sessionDeviceId = null;
      _sessionDeviceName = null;
      _sensorLocation = BodySensorLocation.unknown;
      _currentBatteryLevel = null;
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
      _recorder.startNewSession(deviceId: deviceId, deviceName: deviceName);
      _sessionDeviceId = deviceId;
      _sessionDeviceName = deviceName;
      _sensorLocation = BodySensorLocation.unknown;
      _currentBatteryLevel = null;
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
    } on Object catch (e) {
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
    } on Object catch (e, st) {
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

    final device = _device;
    if (!ref.mounted || device == null || _isDisconnecting) {
      log.w(
        '[HrMonitorNotifier] connect() aborted — notifier disposed or disconnecting '
        'while awaiting physical link.',
      );
      return;
    }

    log.i('[HrMonitorNotifier] Physical link established.');

    _connectionStateSubscription = _monitorService
        .connectionState(device)
        .listen(
          _onDeviceConnectionStateChanged,
          onError: (Object error, StackTrace stack) {
            log.e(
              '[HrMonitorNotifier] connection-state stream error',
              error: error,
              stackTrace: stack,
            );
          },
        );

    state = const MonitorState.discoveringServices();

    log.i(
      '[HrMonitorNotifier] Discovering GATT services '
      '(timeout: ${_kDiscoverServicesTimeout.inSeconds}s)...',
    );

    List<BluetoothService> services;
    try {
      services = await _monitorService
          .discoverServices(device)
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
    } on Object catch (e, st) {
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

    _sensorLocation = await _gattResolver.readBodySensorLocation(hrService);
    _recorder.setSensorLocationIndex(_sensorLocation.index);

    try {
      await ref
          .read(saveDeviceProfileUseCaseProvider)
          .call(
            macAddress: deviceId,
            name: deviceName,
            sensorLocationIndex: _sensorLocation.index,
          );
    } on Object catch (e) {
      log.e('[HrMonitorNotifier] saveDeviceProfile() failed', error: e);
    }

    log.d(
      '[HrMonitorNotifier] Body sensor location: ${_sensorLocation.displayName}',
    );

    final batteryResult = await _gattResolver.resolveBatteryService(
      services,
      onLevelChanged: _updateStateWithBatteryLevel,
    );
    if (batteryResult.initialLevel != null) {
      _currentBatteryLevel = batteryResult.initialLevel;
    }
    _batteryNotificationSubscription = batteryResult.subscription;

    try {
      await _monitorService.setNotifyValue(hrCharacteristic, true);
    } on Object catch (e, st) {
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

            _recorder.recordSample(measurement.bpm);

            final HrMeasurement enrichedMeasurement = measurement.copyWith(
              sensorLocation: _sensorLocation,
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
    _recorder.startCheckpointTimer(
      isConnected: () => ref.mounted && state is ConnectedMonitorState,
    );
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
    await _recorder.saveFinalSession();
    await _foregroundServiceManager.stopService();
    if (!ref.mounted) return;
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
    _recorder.stopCheckpointTimer();

    try {
      await _safeDisconnectDevice();
      await _recorder.saveFinalSession();
      await _foregroundServiceManager.stopService();
    } on Object catch (e, st) {
      log.e(
        '[HrMonitorNotifier] Error during disconnect()',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (ref.mounted) {
        state = const MonitorState.disconnected();
      }
      _isDisconnecting = false;
      log.i('[HrMonitorNotifier] Disconnection complete.');
    }
  }

  /// Handles app lifecycle state changes for [state], forcing an immediate checkpoint on pause/detach.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(
        _recorder.checkpoint(
          isConnected: ref.mounted && this.state is ConnectedMonitorState,
        ),
      );
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

  void _updateStateWithBatteryLevel(int newLevel) {
    if (!ref.mounted) return;
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
    final device = _device;
    if (device == null) return;
    try {
      await _monitorService.disconnect(device);
      log.d('[HrMonitorNotifier] Link-layer disconnect completed.');
    } on Object catch (e) {
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
    if (_recorder.hasSamples && !_recorder.isSaveInProgress) {
      try {
        await _recorder.saveFinalSession();
      } on Object catch (e, st) {
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
    _recorder.stopCheckpointTimer();

    // 3. Safely disconnect BLE device.
    final deviceToDisconnect = _device;
    if (deviceToDisconnect != null) {
      try {
        await _monitorService.disconnect(deviceToDisconnect);
        log.d(
          '[HrMonitorNotifier] _cleanup: Successfully disconnected from device.',
        );
      } on Object catch (e, st) {
        log.w(
          '[HrMonitorNotifier] _cleanup disconnect error',
          error: e,
          stackTrace: st,
        );
      }
    }
    _device = null;

    // 4. Cancel subscriptions sequentially.
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
    } on Object catch (e, st) {
      log.w(
        '[HrMonitorNotifier] _cleanup stopService error',
        error: e,
        stackTrace: st,
      );
    }
  }
}
