import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/ble_device.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart';

part 'ble_scanner_notifier.g.dart';

const Duration _kEmptyStateWindow = Duration(seconds: 6);

const Duration _kHardScanTimeout = Duration(seconds: 15);

const int _kRssiThreshold = -65;

final Guid _kHeartRateServiceUuid = Guid('180d');

@riverpod
class BleScannerNotifier extends _$BleScannerNotifier {
  BluetoothScannerService get _scannerService =>
      ref.read(bluetoothScannerServiceProvider);

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  Timer? _emptyStateTimer;
  List<ScanResult> _lastRawResults = [];
  bool _filtersEnabled = true;

  bool get filtersEnabled => _filtersEnabled;

  @override
  BleScannerState build() {
    _adapterStateSubscription = _scannerService.adapterState.listen(
      _onAdapterStateChanged,
      onError: (Object error, StackTrace stack) {
        debugPrint(
          '[BleScannerNotifier] Adapter state stream error: $error\n$stack',
        );
      },
    );

    ref.onDispose(() => _cleanup());

    return const BleScannerState.idle();
  }

  Future<void> startScan() async {
    if (state is AdapterOffScannerState) {
      debugPrint(
        '[BleScannerNotifier] startScan() skipped — Bluetooth adapter is off.',
      );
      return;
    }

    if (_scannerService.isScanningNow) {
      debugPrint(
        '[BleScannerNotifier] startScan() skipped — scan already in progress.',
      );
      return;
    }

    debugPrint('[BleScannerNotifier] Starting Heart Rate scan...');

    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
    _lastRawResults = [];

    state = BleScannerState.scanning(devices: const []);

    _resetEmptyStateTimer();

    _scanResultsSubscription = _scannerService.scanResults.listen(
      _onScanResultsReceived,
      onError: (Object error, StackTrace stack) {
        debugPrint(
          '[BleScannerNotifier] scanResults stream error: $error\n$stack',
        );
        state = BleScannerState.failure(message: error.toString());
      },
    );

    try {
      await _scannerService.startScan(
        withServices: [_kHeartRateServiceUuid],
        timeout: _kHardScanTimeout,
      );
      debugPrint(
        '[BleScannerNotifier] startScan() returned '
        '(hardware scan window closed).',
      );
    } catch (e) {
      debugPrint('[BleScannerNotifier] startScan() threw: $e');
      _cancelEmptyStateTimer();
      await _scanResultsSubscription?.cancel();
      _scanResultsSubscription = null;
      state = BleScannerState.failure(message: e.toString());
    }
  }

  Future<void> stopScan() async {
    debugPrint('[BleScannerNotifier] Stopping scan...');
    _cancelEmptyStateTimer();

    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;

    await _scannerService.stopScan();

    if (state is ScanningScannerState || state is EmptyScannerState) {
      state = const BleScannerState.idle();
    }
  }

  Future<void> retry() async {
    debugPrint('[BleScannerNotifier] retry() — resetting and restarting scan.');
    await stopScan();
    await startScan();
  }

  void toggleFilters() {
    _filtersEnabled = !_filtersEnabled;
    debugPrint(
      '[BleScannerNotifier] Filters toggled — '
      'filtersEnabled: $_filtersEnabled.',
    );

    if (_lastRawResults.isNotEmpty) {
      _onScanResultsReceived(_lastRawResults);
    }
  }

  void _onAdapterStateChanged(BluetoothAdapterState adapterState) {
    debugPrint('[BleScannerNotifier] Adapter state → ${adapterState.name}');

    switch (adapterState) {
      case BluetoothAdapterState.off:
        _cancelEmptyStateTimer();
        _scanResultsSubscription?.cancel();
        _scanResultsSubscription = null;
        _lastRawResults = [];
        state = const BleScannerState.adapterOff();

      case BluetoothAdapterState.on:
        if (state is AdapterOffScannerState) {
          state = const BleScannerState.idle();
        }

      default:
        break;
    }
  }

  void _onScanResultsReceived(List<ScanResult> results) {
    _lastRawResults = results;

    final Map<String, BleDevice> uniqueDevices = {};

    for (final ScanResult result in results) {
      final String deviceId = result.device.remoteId.str;
      final String platformName = result.device.platformName;
      final int rssi = result.rssi;

      if (_filtersEnabled) {
        if (platformName.isEmpty) continue;
        if (rssi < _kRssiThreshold) continue;
      }

      uniqueDevices[deviceId] = BleDevice(
        id: deviceId,
        name: platformName.isEmpty ? 'Unknown Device' : platformName,
        rssi: rssi,
      );
    }

    final List<BleDevice> qualifiedDevices = uniqueDevices.values.toList(
      growable: false,
    );

    if (qualifiedDevices.isNotEmpty) {
      _cancelEmptyStateTimer();
      state = BleScannerState.scanning(devices: qualifiedDevices);
    } else {
      if (state is ScanningScannerState) {
        _ensureEmptyStateTimerRunning();
        state = BleScannerState.scanning(devices: const []);
      }
    }
  }

  void _resetEmptyStateTimer() {
    _cancelEmptyStateTimer();
    _emptyStateTimer = Timer(_kEmptyStateWindow, _onEmptyStateWindowElapsed);
    debugPrint(
      '[BleScannerNotifier] Empty-state timer armed '
      '(${_kEmptyStateWindow.inSeconds}s window).',
    );
  }

  void _ensureEmptyStateTimerRunning() {
    if (_emptyStateTimer == null || !_emptyStateTimer!.isActive) {
      _emptyStateTimer = Timer(_kEmptyStateWindow, _onEmptyStateWindowElapsed);
      debugPrint(
        '[BleScannerNotifier] Empty-state timer re-armed '
        '(${_kEmptyStateWindow.inSeconds}s window).',
      );
    }
  }

  void _cancelEmptyStateTimer() {
    _emptyStateTimer?.cancel();
    _emptyStateTimer = null;
  }

  void _onEmptyStateWindowElapsed() {
    debugPrint(
      '[BleScannerNotifier] Empty-state window elapsed — '
      'no qualified devices found during active scan.',
    );
    if (state is ScanningScannerState) {
      state = const BleScannerState.empty();
    }
  }

  void _cleanup() {
    debugPrint(
      '[BleScannerNotifier] Disposing — releasing all BLE scan resources.',
    );
    _cancelEmptyStateTimer();
    _scanResultsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription = null;
    _adapterStateSubscription = null;

    if (_scannerService.isScanningNow) {
      _scannerService.stopScan();
    }
  }
}
