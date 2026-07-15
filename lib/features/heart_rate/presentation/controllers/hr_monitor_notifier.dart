import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/core/infrastructure/services/foreground_service_manager.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/monitor_state.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/infrastructure/parsers/hr_packet_parser.dart';
import 'package:ble_heart_rate_monitor/features/workout/infrastructure/repositories/workout_persistence_repository.dart';

part 'hr_monitor_notifier.g.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Maximum time allowed for the physical BLE link-layer handshake to complete.
/// If the native [BluetoothDevice.connect] call does not resolve within this
/// duration, a [TimeoutException] is raised and the state transitions to
/// [FailureMonitorState].
const Duration _kConnectionTimeout = Duration(seconds: 4);

/// Maximum time allowed for GATT service discovery to complete after the link
/// is established. [discoverServices] can hang indefinitely on certain
/// firmware combinations; this boundary guarantees the UI is never permanently
/// stuck in the [DiscoveringServicesMonitorState] screen.
///
/// When this deadline fires, the notifier performs a link-layer disconnect
/// before transitioning to [FailureMonitorState] to prevent resource leaks.
const Duration _kDiscoverServicesTimeout = Duration(seconds: 5);

/// GATT Heart Rate Service UUID (Bluetooth SIG assigned number 0x180D).
final Guid _kHrServiceUuid = Guid('180d');

/// GATT Heart Rate Measurement Characteristic UUID (0x2A37).
final Guid _kHrMeasurementCharUuid = Guid('2a37');

/// GATT Body Sensor Location Characteristic UUID (0x2A38).
final Guid _kBodySensorLocationCharUuid = Guid('2a38');

/// GATT Battery Service UUID (Bluetooth SIG assigned number 0x180F).
final Guid _kBatteryServiceUuid = Guid('180f');

/// GATT Battery Level Characteristic UUID (0x2A19).
final Guid _kBatteryLevelCharacteristicUuid = Guid('2a19');

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// State machine notifier governing the complete BLE connection and heart rate
/// streaming lifecycle for a single active sensor session.
///
/// ### Lifecycle
///
/// 1. **disconnected** — initial state; no resources held.
/// 2. **connecting** — [BluetoothDevice.connect] is in flight (≤ [_kConnectionTimeout]).
/// 3. **discoveringServices** — link is up; GATT enumeration is in flight
///    (≤ [_kDiscoverServicesTimeout]).  If the timeout fires, a link-layer
///    disconnect is executed and the state transitions to [failure].
/// 4. **connected(measurement)** — GATT notifications are active; state is
///    updated with every decoded [HrMeasurement] packet.
/// 5. **failure(message)** — a non-recoverable error terminated the session.
///    The UI should render a recovery screen with a "Retry" CTA.
///
/// ### Timeout contract
///
/// [discoverServices] is guarded with a **strict 5-second timeout boundary**.
/// When the deadline fires:
///   - [FlutterBluePlus] is instructed to disconnect at the link layer.
///   - The GATT notification subscription is cancelled.
///   - The state transitions to [FailureMonitorState] with a user-facing message.
///   - No dangling resources are left alive.
///
/// ### Disposal
///
/// All stream subscriptions are cancelled in [_cleanup], which is registered
/// with [ref.onDispose]. The active [BluetoothDevice] is disconnected if the
/// notifier is disposed while a session is live.
@riverpod
class HrMonitorNotifier extends _$HrMonitorNotifier {
  // --- Active BLE device reference -------------------------------------------

  /// The currently targeted [BluetoothDevice]. Null when in [disconnected] state.
  BluetoothDevice? _device;

  // --- Stream subscriptions ---------------------------------------------------

  /// Subscription to [BluetoothCharacteristic.onValueReceived] for the Heart Rate
  /// Measurement characteristic (0x2A37). Drives state updates from raw bytes
  /// decoded by [HrPacketParser].
  StreamSubscription<List<int>>? _hrNotificationSubscription;

  /// Subscription to [BluetoothDevice.connectionState]. Used to detect
  /// unexpected link-layer disconnections (e.g., device moved out of range)
  /// and surface them as [FailureMonitorState] without the user pressing
  /// "Disconnect" first.
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  /// Subscription to [BluetoothCharacteristic.onValueReceived] for the Battery
  /// Level characteristic (0x2A19). Drives live battery percentage updates.
  StreamSubscription<List<int>>? _batteryNotificationSubscription;

  // --- Session persistence state ---------------------------------------------

  /// Accumulated BPM samples collected during the active session. Flushed to disk
  /// via [_saveSessionToDisk] on disconnect or unexpected disconnection, then
  /// cleared to prepare for the next session.
  final List<int> _collectedBpmSamples = [];

  /// Timestamp when the current session began. Null when no session is active.
  DateTime? _sessionStartTime;

  /// MAC address / unique identifier of the sensor for the current session.
  String? _sessionDeviceId;

  /// Human-readable name of the sensor for the current session.
  String? _sessionDeviceName;

  /// Integer index of the resolved [BodySensorLocation] for the current session.
  /// Read once during GATT discovery and persisted alongside the workout session.
  int? _sessionSensorLocationIndex;

  /// Latest battery percentage received from the sensor's Battery Service.
  /// Null if the device does not expose a Battery Service or the read failed.
  int? _currentBatteryLevel;

  // ---------------------------------------------------------------------------
  // Riverpod build — register disposal and return initial state
  // ---------------------------------------------------------------------------

  /// Registers the [_cleanup] disposal callback and returns the initial
  /// [MonitorState.disconnected] state.
  ///
  /// Riverpod invokes [build] when the provider is first created. The
  /// [ref.onDispose] registration guarantees that [_cleanup] runs when the
  /// provider is removed from the [ProviderScope] (e.g., app termination or
  /// explicit provider disposal).
  @override
  MonitorState build() {
    ref.onDispose(() => _cleanup());
    return const MonitorState.disconnected();
  }

  // ---------------------------------------------------------------------------
  // Public interface
  // ---------------------------------------------------------------------------

  /// Initiates the full two-phase connection sequence for [deviceId].
  ///
  /// **Phase 1 — Physical link (≤ [_kConnectionTimeout]):**
  /// Calls [BluetoothDevice.connect]. Transitions through [connecting].
  ///
  /// **Phase 2 — GATT discovery (≤ [_kDiscoverServicesTimeout]):**
  /// Calls [discoverServices]. Transitions through [discoveringServices].
  /// If the timeout fires, the link is torn down and [failure] is emitted.
  ///
  /// **Phase 3 — Streaming:**
  /// Enables GATT notifications on 0x2A37 and subscribes to incoming packets.
  /// Every successfully decoded [HrMeasurement] updates state to [connected].
  ///
  /// The method is idempotent: a second call while [connecting] or
  /// [discoveringServices] is in progress is safely ignored.
  Future<void> connect(String deviceId, String deviceName) async {
    if (state is ConnectingMonitorState ||
        state is DiscoveringServicesMonitorState) {
      debugPrint(
        '[HrMonitorNotifier] connect() ignored — a connection attempt '
        'is already in progress.',
      );
      return;
    }

    // Release any resources from a previous session before starting a new one.
    await _cancelSubscriptions();
    _collectedBpmSamples.clear();
    _sessionStartTime = DateTime.now();
    _sessionDeviceId = deviceId;
    _sessionDeviceName = deviceName;
    _sessionSensorLocationIndex = null;

    _device = BluetoothDevice.fromId(deviceId);

    debugPrint(
      '[HrMonitorNotifier] Connecting to "$deviceName" ($deviceId)...',
    );

    // --- Phase 1: Physical link-layer handshake --------------------------------
    state = const MonitorState.connecting();

    // Start foreground service to protect connection before establishing it
    await ref.read(foregroundServiceManagerProvider).startService();

    try {
      await _device!.connect(autoConnect: false).timeout(_kConnectionTimeout);
    } on TimeoutException {
      debugPrint(
        '[HrMonitorNotifier] Physical connection timed out after '
        '${_kConnectionTimeout.inSeconds}s.',
      );
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'Connection timed out. Make sure the sensor is nearby and powered on.',
      );
      return;
    } catch (e, st) {
      debugPrint('[HrMonitorNotifier] connect() threw unexpectedly: $e\n$st');
      await _safeDisconnectDevice();
      state = MonitorState.failure(
        message: 'Failed to connect: ${e.toString()}',
      );
      return;
    }

    debugPrint(
      '[HrMonitorNotifier] Physical link established for "$deviceName".',
    );

    // Subscribe to the device's connection state stream so unexpected drops
    // (range loss, sensor power-off) are surfaced to the UI immediately.
    _connectionStateSubscription = _device!.connectionState.listen(
      _onDeviceConnectionStateChanged,
    );

    // --- Phase 2: GATT service discovery --------------------------------------
    state = const MonitorState.discoveringServices();

    debugPrint(
      '[HrMonitorNotifier] Discovering GATT services '
      '(timeout: ${_kDiscoverServicesTimeout.inSeconds}s)...',
    );

    List<BluetoothService> services;
    try {
      services = await _device!.discoverServices().timeout(
        _kDiscoverServicesTimeout,
        // No onTimeout callback: allow the TimeoutException to propagate so
        // the catch block below can execute the mandatory link-layer teardown.
      );
    } on TimeoutException {
      // STRICT TIMEOUT CONTRACT: discoverServices froze beyond the deadline.
      // Execute a link-layer disconnect before transitioning to failure so no
      // orphaned GATT connection consumes system resources.
      debugPrint(
        '[HrMonitorNotifier] discoverServices() exceeded '
        '${_kDiscoverServicesTimeout.inSeconds}s deadline — '
        'executing mandatory link-layer disconnect.',
      );
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'Service discovery timed out. Please move closer to the sensor and retry.',
      );
      return;
    } catch (e, st) {
      debugPrint('[HrMonitorNotifier] discoverServices() threw: $e\n$st');
      await _safeDisconnectDevice();
      state = MonitorState.failure(
        message: 'Service discovery failed: ${e.toString()}',
      );
      return;
    }

    debugPrint(
      '[HrMonitorNotifier] Discovered ${services.length} GATT service(s).',
    );

    // --- Validate Heart Rate Service presence ---------------------------------
    final BluetoothService? hrService = services
        .where((BluetoothService s) => s.serviceUuid == _kHrServiceUuid)
        .firstOrNull;

    if (hrService == null) {
      debugPrint(
        '[HrMonitorNotifier] Heart Rate Service (0x180D) not found — '
        'this device is not a standard HR sensor.',
      );
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'Heart Rate Service (0x180D) not found. '
            'Ensure you are connecting to a heart rate sensor.',
      );
      return;
    }

    // --- Validate HR Measurement Characteristic presence ----------------------
    final BluetoothCharacteristic? hrCharacteristic = hrService.characteristics
        .where(
          (BluetoothCharacteristic c) =>
              c.characteristicUuid == _kHrMeasurementCharUuid,
        )
        .firstOrNull;

    if (hrCharacteristic == null) {
      debugPrint(
        '[HrMonitorNotifier] HR Measurement Characteristic (0x2A37) not found '
        'on the Heart Rate Service.',
      );
      await _safeDisconnectDevice();
      state = const MonitorState.failure(
        message:
            'HR Measurement Characteristic (0x2A37) not found. '
            'This sensor may use a non-standard firmware profile.',
      );
      return;
    }

    // --- Optional: read Body Sensor Location (0x2A38) -------------------------
    // This is a best-effort read. Any error is silently swallowed so a firmware
    // that omits 0x2A38 does not block the telemetry stream from starting.
    final BodySensorLocation sensorLocation = await _readBodySensorLocation(
      hrService,
    );

    _sessionSensorLocationIndex = sensorLocation.index;

    // Cache the device profile directly into the local Isar database.
    ref
        .read(workoutPersistenceRepositoryProvider)
        .saveDeviceProfile(
          macAddress: deviceId,
          name: deviceName,
          sensorLocationIndex: sensorLocation.index,
        );

    debugPrint(
      '[HrMonitorNotifier] Body sensor location: ${sensorLocation.displayName}',
    );

    // --- Optional: resolve Battery Service (0x180F) -------------------------
    // Best-effort discovery. If the sensor omits the Battery Service, we
    // gracefully fall back to null without interrupting the HR stream.
    await _resolveBatteryService(services);

    // --- Phase 3: Enable GATT notifications and begin streaming ---------------
    try {
      await hrCharacteristic.setNotifyValue(true);
    } catch (e, st) {
      debugPrint('[HrMonitorNotifier] setNotifyValue(true) failed: $e\n$st');
      await _safeDisconnectDevice();
      state = MonitorState.failure(
        message: 'Failed to enable HR notifications: ${e.toString()}',
      );
      return;
    }

    debugPrint(
      '[HrMonitorNotifier] GATT HR notifications active — streaming live data.',
    );

    _hrNotificationSubscription = hrCharacteristic.onValueReceived.listen(
      (List<int> rawBytes) {
        final HrMeasurement? measurement = HrPacketParser.parseRawBytes(
          rawBytes,
        );
        if (measurement == null) return;

        // Persist the raw integer directly into our telemetry buffer
        _collectedBpmSamples.add(measurement.bpm);

        // Stamp the dynamically resolved sensor location onto every emitted
        // measurement. The location is read once at session start and held
        // constant — it does not change while the device is connected.
        final HrMeasurement enrichedMeasurement = HrMeasurement(
          bpm: measurement.bpm,
          rrIntervals: measurement.rrIntervals,
          timestamp: measurement.timestamp,
          sensorLocation: sensorLocation,
          batteryLevel: _currentBatteryLevel ?? measurement.batteryLevel,
        );

        state = MonitorState.connected(measurement: enrichedMeasurement);
      },
      onError: (Object error, StackTrace stack) {
        debugPrint(
          '[HrMonitorNotifier] HR notification stream error: $error\n$stack',
        );
        state = MonitorState.failure(
          message: 'Live data stream error: ${error.toString()}',
        );
      },
      onDone: () {
        // The characteristic stream closed, typically because the device
        // disconnected. Only transition if we haven't already surfaced a
        // failure state (e.g., from the connection state listener).
        debugPrint(
          '[HrMonitorNotifier] HR notification stream closed by remote device.',
        );
        if (state is ConnectedMonitorState) {
          state = const MonitorState.disconnected();
        }
      },
      cancelOnError: false,
    );
  }

  /// Gracefully terminates the active connection, cancels all subscriptions,
  /// and transitions to [DisconnectedMonitorState].
  Future<void> disconnect() async {
    debugPrint('[HrMonitorNotifier] disconnect() called.');
    await _saveSessionToDisk();
    await _cancelSubscriptions();
    await _safeDisconnectDevice();
    await ref.read(foregroundServiceManagerProvider).stopService();
    state = const MonitorState.disconnected();
  }

  /// Flushes collected session telemetry to disk asynchronously via the repository,
  /// then clears the in-memory session state to prepare for the next session.
  ///
  /// The persistence call is wrapped in a try-catch-finally block to guarantee
  /// that in-memory state is always reset, even if the database write fails.
  /// Foreground service lifecycle is managed by [disconnect] and is not
  /// duplicated here to avoid double-stop when both are in the call stack.
  Future<void> _saveSessionToDisk() async {
    try {
      if (_collectedBpmSamples.isNotEmpty &&
          _sessionStartTime != null &&
          _sessionDeviceId != null &&
          _sessionDeviceName != null) {
        final repo = ref.read(workoutPersistenceRepositoryProvider);

        final samples = List<int>.from(_collectedBpmSamples);
        final startTime = _sessionStartTime!;
        final endTime = DateTime.now();

        await repo.saveWorkoutSession(
          startTime: startTime,
          endTime: endTime,
          samples: samples,
          sensorLocationIndex:
              _sessionSensorLocationIndex ?? BodySensorLocation.other.index,
          macAddress: _sessionDeviceId!,
          name: _sessionDeviceName!,
        );
      }
    } catch (e) {
      debugPrint(
        '[HrMonitorNotifier] Failed to persist workout session (data may be lost): $e',
      );
    } finally {
      _collectedBpmSamples.clear();
      _sessionStartTime = null;
      _sessionDeviceId = null;
      _sessionDeviceName = null;
      _sessionSensorLocationIndex = null;
    }
  }

  /// Convenience method combining [disconnect] and [connect] for the UI
  /// "Retry" CTA on the [FailureMonitorState] recovery screen.
  ///
  /// This ensures all stale resources are fully released before a fresh
  /// connection attempt begins, preventing GATT handle leaks.
  Future<void> retry(String deviceId, String deviceName) async {
    debugPrint(
      '[HrMonitorNotifier] retry() — tearing down current session '
      'then reconnecting to "$deviceName".',
    );
    await disconnect();
    await connect(deviceId, deviceName);
  }

  // ---------------------------------------------------------------------------
  // Private — optional GATT reads
  // ---------------------------------------------------------------------------

  /// Attempts to read the Body Sensor Location from characteristic 0x2A38.
  ///
  /// Returns [BodySensorLocation.unknown] on any error so that an optional
  /// GATT characteristic never blocks the critical HR data stream.
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

      final List<int> bytes = await locationChar.read().timeout(
        const Duration(seconds: 2),
      );

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
      debugPrint(
        '[HrMonitorNotifier] Optional 0x2A38 read failed (ignored): $e',
      );
      return BodySensorLocation.unknown;
    }
  }

  /// Best-effort resolution of the Battery Service (0x180F) and Battery Level
  /// Characteristic (0x2A19).
  ///
  /// Executes a guarded initial read (2 s timeout), then optionally enables
  /// notifications if the GATT properties allow it. Any failure is logged and
  /// swallowed — the primary HR telemetry stream is never blocked.
  Future<void> _resolveBatteryService(List<BluetoothService> services) async {
    try {
      final BluetoothService? batteryService = services
          .where((BluetoothService s) => s.serviceUuid == _kBatteryServiceUuid)
          .firstOrNull;

      if (batteryService == null) {
        debugPrint(
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
        debugPrint(
          '[HrMonitorNotifier] Battery Level Characteristic (0x2A19) not found.',
        );
        return;
      }

      // Guarded initial read — 2 s timeout so a slow GATT response does not
      // hold up the connection flow.
      try {
        final List<int> initialBytes = await batteryChar.read().timeout(
          const Duration(seconds: 2),
        );
        if (initialBytes.isNotEmpty) {
          _currentBatteryLevel = initialBytes.first.clamp(0, 100);
          debugPrint(
            '[HrMonitorNotifier] Initial battery level read: $_currentBatteryLevel%',
          );
        }
      } on TimeoutException {
        debugPrint(
          '[HrMonitorNotifier] Battery level initial read timed out (2 s) — '
          'will rely on notifications if available.',
        );
      } catch (e) {
        debugPrint('[HrMonitorNotifier] Battery level initial read failed: $e');
      }

      // Enable notifications only if the characteristic advertises the property.
      final bool supportsNotify = batteryChar.properties.notify;
      final bool supportsIndicate = batteryChar.properties.indicate;

      if (supportsNotify || supportsIndicate) {
        await batteryChar.setNotifyValue(true);
        _batteryNotificationSubscription = batteryChar.onValueReceived.listen(
          (List<int> bytes) {
            if (bytes.isNotEmpty) {
              _updateStateWithBatteryLevel(bytes.first.clamp(0, 100));
            }
          },
          onError: (Object error, StackTrace stack) {
            debugPrint(
              '[HrMonitorNotifier] Battery notification stream error: $error',
            );
          },
          cancelOnError: false,
        );
      } else {
        debugPrint(
          '[HrMonitorNotifier] Battery characteristic found but does not '
          'support notifications/indications. Using initial read value.',
        );
      }
    } catch (e) {
      debugPrint(
        '[HrMonitorNotifier] Battery service resolution failed (ignored): $e',
      );
    }
  }

  /// Parses a new battery percentage and synchronizes it into both the cached
  /// field and the active [ConnectedMonitorState] (if currently connected).
  ///
  /// Only triggers a state transition when the value actually changes, avoiding
  /// unnecessary UI repaints.
  void _updateStateWithBatteryLevel(int newLevel) {
    if (_currentBatteryLevel == newLevel) return;
    _currentBatteryLevel = newLevel;
    debugPrint('[HrMonitorNotifier] Battery level updated: $newLevel%');

    if (state is ConnectedMonitorState) {
      final current = state as ConnectedMonitorState;
      state = MonitorState.connected(
        measurement: HrMeasurement(
          bpm: current.measurement.bpm,
          rrIntervals: current.measurement.rrIntervals,
          timestamp: current.measurement.timestamp,
          sensorLocation: current.measurement.sensorLocation,
          batteryLevel: newLevel,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private — connection state watcher
  // ---------------------------------------------------------------------------

  /// Handles unexpected link-layer disconnection events from the device.
  ///
  /// If the device drops the connection while data is streaming (e.g., sensor
  /// battery dies, device moves out of range), this callback surfaces a
  /// [FailureMonitorState] so the UI shows the recovery screen immediately.
  void _onDeviceConnectionStateChanged(
    BluetoothConnectionState connectionState,
  ) {
    debugPrint(
      '[HrMonitorNotifier] Device connection state → ${connectionState.name}',
    );

    if (connectionState == BluetoothConnectionState.disconnected) {
      // Guard against firing during an intentional disconnect triggered by
      // the user, which already transitions state via disconnect().
      if (state is ConnectedMonitorState ||
          state is ConnectingMonitorState ||
          state is DiscoveringServicesMonitorState) {
        debugPrint(
          '[HrMonitorNotifier] Unexpected disconnection detected — '
          'surfacing failure state.',
        );
        _hrNotificationSubscription?.cancel();
        _batteryNotificationSubscription?.cancel();
        _hrNotificationSubscription = null;
        _batteryNotificationSubscription = null;
        _saveSessionToDisk(); // Flush recorded session safely
        state = const MonitorState.failure(
          message:
              'Connection lost. The sensor may be out of range or powered off.',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Private — resource management
  // ---------------------------------------------------------------------------

  /// Cancels all active stream subscriptions without touching the BLE link.
  /// Called before starting a new session to prevent events from a stale
  /// subscription polluting the new state machine.
  Future<void> _cancelSubscriptions() async {
    await _hrNotificationSubscription?.cancel();
    await _batteryNotificationSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    _hrNotificationSubscription = null;
    _batteryNotificationSubscription = null;
    _connectionStateSubscription = null;
  }

  /// Instructs [FlutterBluePlus] to disconnect [_device] at the link layer.
  ///
  /// All errors are caught and logged rather than re-thrown so that a failed
  /// disconnect attempt never cascades into an unhandled exception inside an
  /// already-failing error-handling path.
  Future<void> _safeDisconnectDevice() async {
    if (_device == null) return;
    try {
      await _device!.disconnect();
      debugPrint(
        '[HrMonitorNotifier] Link-layer disconnect completed for '
        '${_device!.remoteId}.',
      );
    } catch (e) {
      debugPrint(
        '[HrMonitorNotifier] _safeDisconnectDevice() error (logged, not re-thrown): $e',
      );
    } finally {
      _device = null;
    }
  }

  /// Full disposal: cancels subscriptions and disconnects the device.
  /// Registered with [ref.onDispose] and called synchronously by Riverpod.
  ///
  /// Riverpod's [onDispose] callback is **synchronous** — it does not support
  /// `async`/`await`. Because BLE disconnect and subscription cancel operations
  /// return `Future`s, this method invokes them as fire-and-forget calls. This
  /// is intentional: it prevents the disposal pipeline from blocking while
  /// still ensuring that all resources are released. The catch-all error
  /// handling in [_safeDisconnectDevice] and [StreamSubscription.cancel]
  /// guarantees that a failed teardown never surfaces as an unhandled exception.
  void _cleanup() {
    debugPrint(
      '[HrMonitorNotifier] Disposing — releasing all GATT and BLE resources.',
    );
    // Fire-and-forget async operations from a sync dispose callback.
    // Riverpod does not await onDispose callbacks; best-effort teardown is
    // the correct behaviour here to avoid holding up ProviderScope disposal.
    _hrNotificationSubscription?.cancel();
    _batteryNotificationSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _hrNotificationSubscription = null;
    _batteryNotificationSubscription = null;
    _connectionStateSubscription = null;
    _device?.disconnect();
    _device = null;
    ref.read(foregroundServiceManagerProvider).stopService();
  }
}
