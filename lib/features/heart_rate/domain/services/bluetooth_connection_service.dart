import '../models/ble_connection_status.dart';

abstract class BluetoothConnectionService {
  Stream<BleConnectionStatus> get connectionStatus;

  Future<void> connect(String deviceId);
  Future<void> disconnect();
}