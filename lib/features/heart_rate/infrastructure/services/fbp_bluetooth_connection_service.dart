import 'dart:async';

import 'package:flutter/foundation.dart'; // used for debugPrint
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/ble_connection_status.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/services/bluetooth_connection_service.dart';

/// FlutterBluePlus implementation of the connection service, safe for production releases.
///
/// Manages a single active BLE connection at a time. Emits [BleConnectionStatus]
/// updates via a broadcast stream so multiple listeners can react to state changes.
class FbpBluetoothConnectionService implements BluetoothConnectionService {
  /// The currently connected peripheral, or `null` when disconnected.
  BluetoothDevice? _activeDevice;

  /// Broadcast controller that emits connection state transitions.
  final _statusController = StreamController<BleConnectionStatus>.broadcast();

  @override
  /// Stream of connection state changes for the active peripheral.
  Stream<BleConnectionStatus> get connectionStatus => _statusController.stream;

  @override
  /// Connects to the peripheral identified by [deviceId].
  ///
  /// Emits [BleConnectionStatus.connecting] immediately, followed by either
  /// [BleConnectionStatus.connected] on success or [BleConnectionStatus.disconnected]
  /// plus an error on failure. The native connect call is bounded by a 4-second timeout.
  Future<void> connect(String deviceId) async {
    try {
      debugPrint('--- [CONN SERVICE] Initializing connection to $deviceId ---');
      _statusController.add(BleConnectionStatus.connecting);

      _activeDevice = BluetoothDevice.fromId(deviceId);

      await _activeDevice!
          .connect(autoConnect: false)
          .timeout(
            const Duration(seconds: 4),
            onTimeout: () => throw TimeoutException(
              'Native BLE connection handshake timed out',
            ),
          );

      debugPrint(
        '--- [CONN SERVICE] Native connect() completed successfully ---',
      );
      _statusController.add(BleConnectionStatus.connected);
    } catch (e) {
      debugPrint('--- [CONN SERVICE] Error during connection setup: $e ---');
      _statusController.add(BleConnectionStatus.disconnected);
      _statusController.addError(e);
    }
  }

  @override
  /// Disconnects from the active peripheral and clears the internal device reference.
  ///
  /// Emits [BleConnectionStatus.disconnected] upon completion. No-op if already disconnected.
  Future<void> disconnect() async {
    if (_activeDevice != null) {
      debugPrint(
        '--- [CONN SERVICE] Disconnecting from ${_activeDevice!.remoteId} ---',
      );
      await _activeDevice!.disconnect();
      _statusController.add(BleConnectionStatus.disconnected);
      _activeDevice = null;
    }
  }
}
