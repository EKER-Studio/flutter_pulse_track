import '../models/ble_connection_status.dart';

/// Contract for managing the lifecycle of a physical connection with a BLE device.
abstract class BluetoothConnectionService {
  /// Stream emitting continuous updates of the active connection state.
  Stream<BleConnectionStatus> get connectionStatus;

  /// Establishes a native link with the specified peripheral.
  Future<void> connect(String deviceId);

  /// Terminates the active connection and releases system resources.
  Future<void> disconnect();
}
