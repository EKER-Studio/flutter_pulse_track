import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/ble_device.dart';
import '../../domain/services/bluetooth_scanner_service.dart';
import '../../infrastructure/services/fbp_bluetooth_scanner_service.dart';

part 'bluetooth_scanner_providers.g.dart';

@riverpod
BluetoothScannerService bluetoothScannerService(Ref ref) {
  return FbpBluetoothScannerService();
}

@riverpod
Stream<List<BleDevice>> bleScanResults(Ref ref) {
  final scannerService = ref.watch(bluetoothScannerServiceProvider);
  return scannerService.scanResults;
}

@riverpod
class BluetoothScannerController extends _$BluetoothScannerController {
  @override
  Stream<bool> build() {
    final scannerService = ref.watch(bluetoothScannerServiceProvider);
    return scannerService.isScanning;
  }

  Future<void> startHeartRateScan() async {
    final scannerService = ref.read(bluetoothScannerServiceProvider);
    await scannerService.startScan(withServices: ['180D']);
  }

  Future<void> stopScan() async {
    final scannerService = ref.read(bluetoothScannerServiceProvider);
    await scannerService.stopScan();
  }
}