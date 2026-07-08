import '../models/ble_device.dart';

abstract class BluetoothScannerService {
  Stream<List<BleDevice>> get scanResults;
  Stream<bool> get isScanning;

  Future<void> startScan({List<String>? withServices});
  Future<void> stopScan();
}