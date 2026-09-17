import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart';

export 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart'
    show BluetoothScannerService;
export 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_heart_rate_monitor_service.dart'
    show HeartRateMonitorService;

part 'ble_providers.g.dart';

@Riverpod(keepAlive: true)
BluetoothScannerService bluetoothScannerService(Ref ref) =>
    FbpBluetoothScannerService();

@Riverpod(keepAlive: true)
HeartRateMonitorService heartRateMonitorService(Ref ref) =>
    FbpHeartRateMonitorService();
