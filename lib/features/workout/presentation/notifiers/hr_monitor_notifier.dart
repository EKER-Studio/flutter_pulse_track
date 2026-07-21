import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/usecases/save_workout_session_usecase.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/value_objects/heart_rate_service_uuid.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/value_objects/sensor_location_name.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/value_objects/ble_device_name.dart';

part 'hr_monitor_notifier.g.dart';

/// Riverpod provider that manages the heart-rate monitoring lifecycle.
///
/// Scans for BLE devices, connects to the first heart-rate sensor it finds,
/// subscribes to its heart-rate characteristic, and exposes the collected BPM
/// samples as a reactive [AsyncValue] stream.
///
/// Periodically checkpoints accumulated BPM samples to Isar every 30 seconds
/// to prevent data loss if the process is terminated while the app is in the
/// background. On lifecycle transitions to [AppLifecycleState.paused] or
/// [AppLifecycleState.detached], the current session is synchronously flushed
/// to disk before the app leaves the foreground.
@riverpod
class HrMonitorNotifier extends _$HrMonitorNotifier
    with WidgetsBindingObserver {
  static const _checkpointInterval = Duration(seconds: 30);

  Timer? _checkpointTimer;
  StreamSubscription<CharacteristicWithClient<BluetoothGattAttCharacteristic>>?
  _hrCharacteristicSubscription;

  /// Holds the current workout session's BPM samples.
  final List<int> _collectedBpmSamples = [];

  /// Marks the start time of the active workout session.
  late DateTime _sessionStartTime;

  /// Sensor location index captured at connection time.
  late int _sensorLocationIndex;

  /// MAC address of the connected sensor.
  late String _macAddress;

  /// Human-readable device name captured at connection time.
  late String _deviceName;

  /// The currently connected [BluetoothDevice], if any.
  BluetoothDevice? _connectedDevice;

  /// Whether a workout session is currently active.
  bool get _isSessionActive => _connectedDevice != null;

  /// Starts periodic checkpoint writes to Isar.
  void _startCheckpointTimer() {
    stopCheckpointTimer();
    _checkpointTimer = Timer.periodic(
      _checkpointInterval,
      (_) => _checkpoint(),
    );
  }

  /// Stops the periodic checkpoint timer.
  void stopCheckpointTimer() {
    _checkpointTimer?.cancel();
    _checkpointTimer = null;
  }

  /// Writes the accumulated samples to Isar as a partial checkpoint.
  ///
  /// The checkpoint record has [endTime] set to `null`, keeping it in an
  /// "active" state so the final [SaveWorkoutSessionUseCase] call can complete
  /// the session with accurate timing and the full sample list.
  Future<void> _checkpoint() async {
    if (!_isSessionActive || _collectedBpmSamples.isEmpty) return;

    try {
      final savePartial = ref.read(savePartialWorkoutSessionUseCaseProvider);
      await savePartial(
        startTime: _sessionStartTime,
        samples: List.unmodifiable(_collectedBpmSamples),
        sensorLocationIndex: _sensorLocationIndex,
        macAddress: _macAddress,
        name: _deviceName,
      );
      debugPrint(
        'Workout checkpoint saved at ${DateTime.now().toLocal()} with ${_collectedBpmSamples.length} samples',
      );
    } catch (e) {
      debugPrint('Failed to save workout checkpoint: $e');
    }
  }

  /// Flushes the current session state to Isar with a final [endTime].
  ///
  /// Cancels the checkpoint timer and clears the sample buffer after writing.
  Future<void> _flushSession() async {
    if (!_isSessionActive || _collectedBpmSamples.isEmpty) return;

    try {
      stopCheckpointTimer();

      final save = ref.read(saveWorkoutSessionUseCaseProvider);
      await save(
        startTime: _sessionStartTime,
        endTime: DateTime.now(),
        samples: List.unmodifiable(_collectedBpmSamples),
        sensorLocationIndex: _sensorLocationIndex,
        macAddress: _macAddress,
        name: _deviceName,
      );
      debugPrint(
        'Workout session flushed at ${DateTime.now().toLocal()} with ${_collectedBpmSamples.length} samples',
      );
    } catch (e) {
      debugPrint('Failed to flush workout session: $e');
    } finally {
      _collectedBpmSamples.clear();
    }
  }

  /// Called on lifecycle transitions.
  ///
  /// When the app is about to leave the foreground ([paused] or [detached]),
  /// flushes the current session to Isar immediately.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _flushSession().ignore();
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _hrCharacteristicSubscription?.cancel();
    _hrCharacteristicSubscription = null;
    stopCheckpointTimer();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() {
    WidgetsBinding.instance.addObserver(this);
    return super.didChangeDependencies();
  }

  /// Starts scanning for heart-rate BLE devices and connects to the first one.
  @override
  Future<void> build() async {
    super.build();
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      final device = await FlutterBluePlus.findAnyDevice(
        forServices: [heartRateServiceUuid],
        timeout: const Duration(seconds: 5),
      );

      if (device == null) {
        state = AsyncError('No heart-rate device found', StackTrace.current);
        return;
      }

      await device.connect();
      _connectedDevice = device;
      _macAddress = device.platformName;
      _deviceName = device.platformName;
      _sessionStartTime = DateTime.now();

      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.serviceUuid == heartRateServiceUuid,
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.characteristicUuid == heartRateCharacteristicUuid,
      );

      await characteristic.setNotifyValue(true);
      _hrCharacteristicSubscription = characteristic.onValueReceived.listen((
        value,
      ) {
        if (value.value.length >= 2) {
          final isBitSet = value.value[0] & 0x01;
          int hrValue;
          int locationIndex;

          if (isBitSet == 1) {
            hrValue = value.value[1];
            locationIndex = 255;
          } else {
            hrValue = value.value[1] | (value.value[2] << 8);
            locationIndex = value.value[3];
          }

          _sensorLocationIndex = locationIndex;

          final locationName = sensorLocationName(locationIndex);

          if (hrValue > 0) {
            _collectedBpmSamples.add(hrValue);
            state = AsyncData(hrValue);
            debugPrint('Heart rate: $hrValue bpm | Location: $locationName');
          }
        }
      });

      _startCheckpointTimer();

      debugPrint('Connected to heart-rate device: ${device.platformName}');
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  /// Disconnects from the current BLE device and saves the workout session.
  Future<void> disconnect() async {
    await _flushSession();

    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _collectedBpmSamples.clear();
      state = const AsyncData(0);
      debugPrint('Disconnected from heart-rate device');
    }
  }
}
