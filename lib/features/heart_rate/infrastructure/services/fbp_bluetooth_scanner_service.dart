import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/models/ble_device.dart';
import '../../domain/services/bluetooth_scanner_service.dart';

class FbpBluetoothScannerService implements BluetoothScannerService {
  @override
  Stream<List<BleDevice>> get scanResults => FlutterBluePlus.scanResults.map(
        (results) => results
        .map((r) => BleDevice(
      id: r.device.remoteId.str,
      name: r.device.platformName.isEmpty
          ? 'Unknown Device'
          : r.device.platformName,
      rssi: r.rssi,
    ))
        .toList(),
  );

  @override
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  Future<void> startScan({List<String>? withServices}) async {
    final guids = withServices?.map((e) => Guid(e)).toList() ?? [];

    await FlutterBluePlus.startScan(
      withServices: guids,
      timeout: const Duration(seconds: 15),
    );
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
}