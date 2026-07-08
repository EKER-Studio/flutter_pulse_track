import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../domain/models/ble_device.dart';
import '../../domain/services/bluetooth_scanner_service.dart';

/// FlutterBluePlus implementation of the BLE scanner service, optimized for performance and production safe logging.
class FbpBluetoothScannerService implements BluetoothScannerService {
  @override
  Stream<List<BleDevice>> get scanResults => FlutterBluePlus.scanResults.map((
    results,
  ) {
    final Map<String, BleDevice> uniqueDevices = {};

    for (final r in results) {
      final id = r.device.remoteId.str;
      // Keep the strongest or most recent signal, avoiding duplicate entities in the stream
      uniqueDevices[id] = BleDevice(
        id: id,
        name: r.device.platformName.isEmpty
            ? 'Unknown Device'
            : r.device.platformName,
        rssi: r.rssi,
      );
    }

    return uniqueDevices.values.toList();
  });

  @override
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  Future<void> startScan({List<String>? withServices}) async {
    debugPrint(
      '--- [SCAN SERVICE] Starting BLE hardware scan (Timeout: 15s) ---',
    );
    final guids = withServices?.map((e) => Guid(e)).toList() ?? [];

    await FlutterBluePlus.startScan(
      withServices: guids,
      timeout: const Duration(seconds: 15),
    );
  }

  @override
  Future<void> stopScan() async {
    debugPrint('--- [SCAN SERVICE] Manually stopping BLE hardware scan ---');
    await FlutterBluePlus.stopScan();
  }
}
