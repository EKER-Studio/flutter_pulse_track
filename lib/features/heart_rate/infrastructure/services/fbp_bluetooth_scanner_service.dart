import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/ble_device.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/services/bluetooth_scanner_service.dart';

/// FlutterBluePlus implementation of the BLE scanner service, optimized for performance and production safe logging.
///
/// Delegates scanning to the native FlutterBluePlus radio. Deduplicates scan results
/// by device ID, keeping the most recent entry for each peripheral.
class FbpBluetoothScannerService implements BluetoothScannerService {
  @override
  /// Stream of discovered devices, deduplicated by remote ID.
  ///
  /// Maps raw FlutterBluePlus scan results into a list of [BleDevice] domain models.
  /// Devices with an empty platform name are labeled 'Unknown Device'.
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
  /// Stream reflecting whether the BLE radio is actively scanning.
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  /// Starts a hardware scan with a 15-second timeout.
  ///
  /// Optionally filters by service UUIDs passed in [withServices] (e.g., `['180d']`
  /// for the Heart Rate service).
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
  /// Stops the active BLE hardware scan.
  Future<void> stopScan() async {
    debugPrint('--- [SCAN SERVICE] Manually stopping BLE hardware scan ---');
    await FlutterBluePlus.stopScan();
  }
}
