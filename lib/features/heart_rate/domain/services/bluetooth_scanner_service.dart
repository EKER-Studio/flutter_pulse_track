import '../models/ble_device.dart';

/// Contract for discovering nearby Bluetooth Low Energy peripherals.
abstract class BluetoothScannerService {
  /// Stream emitting a list of all currently discovered devices.
  Stream<List<BleDevice>> get scanResults;

  /// Stream emitting the current operational state of the hardware radio scanner.
  Stream<bool> get isScanning;

  /// Starts scanning for nearby devices, optionally filtering by service UUIDs (e.g., ['180d']).
  Future<void> startScan({List<String>? withServices});

  /// Stops the active hardware scan operation.
  Future<void> stopScan();
}
