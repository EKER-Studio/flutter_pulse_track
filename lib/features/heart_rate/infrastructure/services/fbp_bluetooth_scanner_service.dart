import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/utils/app_logger.dart';

part 'fbp_bluetooth_scanner_service.g.dart';

/// Abstraction over the BLE scanner hardware.
///
/// Wraps [FlutterBluePlus] static APIs so that notifiers depend on an
/// injectable contract rather than the concrete BLE library directly.
abstract class BluetoothScannerService {
  /// Broadcast stream of adapter power-state changes.
  Stream<BluetoothAdapterState> get adapterState;

  /// Broadcast stream of incremental scan-result batches. Emitted only while
  /// a hardware scan is active.
  Stream<List<ScanResult>> get scanResults;

  /// Whether the hardware radio is currently scanning.
  bool get isScanningNow;

  /// Initiates a hardware BLE scan.
  Future<void> startScan({required List<Guid> withServices, Duration? timeout});

  /// Halts the active hardware scan.
  Future<void> stopScan();
}

/// Concrete [BluetoothScannerService] backed by [FlutterBluePlus].
class FbpBluetoothScannerService implements BluetoothScannerService {
  @override
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  @override
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  @override
  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  @override
  Future<void> startScan({
    required List<Guid> withServices,
    Duration? timeout,
  }) async {
    try {
      await FlutterBluePlus.startScan(
        withServices: withServices,
        timeout: timeout,
      );
    } catch (e) {
      log.e('[FbpBluetoothScannerService] startScan failed', error: e);
      rethrow;
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      log.e('[FbpBluetoothScannerService] stopScan failed', error: e);
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
BluetoothScannerService bluetoothScannerService(Ref ref) =>
    FbpBluetoothScannerService();
