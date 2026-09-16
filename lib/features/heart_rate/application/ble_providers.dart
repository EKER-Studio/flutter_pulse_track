import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart';

export 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart'
    show BluetoothScannerService;
export 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart'
    show HeartRateMonitorService;

part 'ble_providers.g.dart';

/// Singleton Riverpod provider delivering the [BluetoothScannerService] using [ref].
@Riverpod(keepAlive: true)
BluetoothScannerService bluetoothScannerService(Ref ref) =>
    FbpBluetoothScannerService();

/// Singleton Riverpod provider delivering the [HeartRateMonitorService] using [ref].
@Riverpod(keepAlive: true)
HeartRateMonitorService heartRateMonitorService(Ref ref) =>
    FbpHeartRateMonitorService();
