import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/utils/app_logger.dart';

part 'fbp_heart_rate_monitor_service.g.dart';

/// Abstraction over BLE connection, service discovery, and GATT communication.
///
/// Wraps [BluetoothDevice] operations so that notifiers depend on an injectable
/// contract rather than the concrete BLE library directly.
abstract class HeartRateMonitorService {
  /// Creates a [BluetoothDevice] handle for [deviceId] without connecting.
  BluetoothDevice fromId(String deviceId);

  /// Opens the physical BLE link-layer connection to [device] with optional [autoConnect].
  ///
  /// Returns a [Future] completing when the connection is established.
  Future<void> connect(BluetoothDevice device, {bool autoConnect});

  /// Tears down the physical BLE link-layer connection to [device].
  ///
  /// Returns a [Future] completing when the connection is closed.
  Future<void> disconnect(BluetoothDevice device);

  /// Broadcast stream of connection-state changes for [device].
  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device);

  /// Enumerates all GATT services and characteristics exposed by [device].
  ///
  /// Returns a [Future] with the list of discovered [BluetoothService] objects.
  Future<List<BluetoothService>> discoverServices(BluetoothDevice device);

  /// Enables or disables GATT notifications on [characteristic] based on [value].
  ///
  /// Returns a [Future] completing when notification subscription status updates.
  Future<void> setNotifyValue(
    BluetoothCharacteristic characteristic,
    bool value,
  );

  /// Broadcast stream of incoming notification/indication values for
  /// [characteristic]. Only emits while notifications are enabled.
  Stream<List<int>> onValueReceived(BluetoothCharacteristic characteristic);

  /// Reads the current value of [characteristic] on demand.
  ///
  /// Returns a [Future] completing with raw byte values.
  Future<List<int>> read(BluetoothCharacteristic characteristic);
}

/// Concrete [HeartRateMonitorService] backed by [FlutterBluePlus].
class FbpHeartRateMonitorService implements HeartRateMonitorService {
  /// Creates a new [FbpHeartRateMonitorService] instance.
  FbpHeartRateMonitorService();

  @override
  BluetoothDevice fromId(String deviceId) => BluetoothDevice.fromId(deviceId);

  @override
  Future<void> connect(
    BluetoothDevice device, {
    bool autoConnect = false,
  }) async {
    try {
      await device.connect(autoConnect: autoConnect);
    } catch (e) {
      log.e('[FbpHeartRateMonitorService] connect failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> disconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      log.e('[FbpHeartRateMonitorService] disconnect failed', error: e);
      rethrow;
    }
  }

  @override
  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device) =>
      device.connectionState;

  @override
  Future<List<BluetoothService>> discoverServices(
    BluetoothDevice device,
  ) async {
    try {
      return await device.discoverServices();
    } catch (e) {
      log.e('[FbpHeartRateMonitorService] discoverServices failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> setNotifyValue(
    BluetoothCharacteristic characteristic,
    bool value,
  ) async {
    try {
      await characteristic.setNotifyValue(value);
    } catch (e) {
      log.e('[FbpHeartRateMonitorService] setNotifyValue failed', error: e);
      rethrow;
    }
  }

  @override
  Stream<List<int>> onValueReceived(BluetoothCharacteristic characteristic) =>
      characteristic.onValueReceived;

  @override
  Future<List<int>> read(BluetoothCharacteristic characteristic) async {
    try {
      return await characteristic.read();
    } catch (e) {
      log.e('[FbpHeartRateMonitorService] read failed', error: e);
      rethrow;
    }
  }
}

/// Singleton Riverpod provider delivering the [HeartRateMonitorService] using [ref].
@Riverpod(keepAlive: true)
HeartRateMonitorService heartRateMonitorService(Ref ref) =>
    FbpHeartRateMonitorService();
