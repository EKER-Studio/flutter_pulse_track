import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/ble_device.dart';
import '../../domain/services/bluetooth_scanner_service.dart';
import '../../infrastructure/services/fbp_bluetooth_scanner_service.dart';

part 'bluetooth_scanner_providers.g.dart';

/// Provides the concrete implementation of the Bluetooth scanner service.
@riverpod
BluetoothScannerService bluetoothScannerService(Ref ref) {
  return FbpBluetoothScannerService();
}

/// Exposes a reactive stream of all discovered BLE devices filtered and mapped by infrastructure.
@riverpod
Stream<List<BleDevice>> bleScanResults(Ref ref) {
  final scannerService = ref.watch(bluetoothScannerServiceProvider);
  return scannerService.scanResults;
}

/// Controller managing the execution of hardware scan intents and tracking active scanner lifecycle.
@riverpod
class BluetoothScannerController extends _$BluetoothScannerController {
  @override
  Stream<bool> build() {
    final scannerService = ref.watch(bluetoothScannerServiceProvider);
    return scannerService.isScanning;
  }

  /// Triggers a 15-second hardware scan focused strictly on the standard Heart Rate Service (0x180D).
  Future<void> startHeartRateScan() async {
    final scannerService = ref.read(bluetoothScannerServiceProvider);
    // Lowercase '180d' ensures safe string match resolution across all target native BLE platforms
    await scannerService.startScan(withServices: ['180d']);
  }

  /// Manually interrupts the active hardware scan operation.
  Future<void> stopScan() async {
    final scannerService = ref.read(bluetoothScannerServiceProvider);
    await scannerService.stopScan();
  }
}
