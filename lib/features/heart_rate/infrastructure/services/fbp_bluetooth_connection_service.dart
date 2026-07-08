import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/models/ble_connection_state.dart';
import '../../domain/services/bluetooth_connection_service.dart';

class FbpBluetoothConnectionService implements BluetoothConnectionService {
  BluetoothDevice? _activeDevice;
  StreamSubscription<BluetoothConnectionState>? _stateSubscription;

  final StreamController<BleConnectionStatus> _statusController =
  StreamController<BleConnectionStatus>.broadcast();

  FbpBluetoothConnectionService() {
    _statusController.add(BleConnectionStatus.disconnected);
  }

  @override
  Stream<BleConnectionStatus> get connectionStatus => _statusController.stream;

  @override
  Future<void> connect(String deviceId) async {
    await _stateSubscription?.cancel();

    _statusController.add(BleConnectionStatus.connecting);
    _activeDevice = BluetoothDevice.fromId(deviceId);

    _stateSubscription = _activeDevice!.connectionState.listen((state) {
      switch (state) {
        case BluetoothConnectionState.connected:
          _statusController.add(BleConnectionStatus.connected);
          break;
        case BluetoothConnectionState.disconnected:
          _statusController.add(BleConnectionStatus.disconnected);
          break;
        case BluetoothConnectionState.connecting:
          _statusController.add(BleConnectionStatus.connecting);
          break;
        case BluetoothConnectionState.disconnecting:
          _statusController.add(BleConnectionStatus.disconnecting);
          break;
      }
    });

    try {
      // autoConnect: true delegates reconnection to iOS/Android OS level
      await _activeDevice!.connect(
        autoConnect: true,
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      _statusController.add(BleConnectionStatus.disconnected);
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    await _stateSubscription?.cancel();
    if (_activeDevice != null) {
      _statusController.add(BleConnectionStatus.disconnecting);
      await _activeDevice!.disconnect();
    }
    _statusController.add(BleConnectionStatus.disconnected);
    _activeDevice = null;
  }
}