import 'dart:async';

import 'package:flutter/foundation.dart'; // used for debugPrint
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../domain/models/ble_connection_status.dart';
import '../../domain/services/bluetooth_connection_service.dart';

/// FlutterBluePlus implementation of the connection service, safe for production releases.
class FbpBluetoothConnectionService implements BluetoothConnectionService {
  BluetoothDevice? _activeDevice;
  final _statusController = StreamController<BleConnectionStatus>.broadcast();

  @override
  Stream<BleConnectionStatus> get connectionStatus => _statusController.stream;

  @override
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
