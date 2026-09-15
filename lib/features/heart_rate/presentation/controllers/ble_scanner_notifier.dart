import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/infrastructure/services/fbp_bluetooth_scanner_service.dart';

part 'ble_scanner_notifier.g.dart';

const Duration _kEmptyStateWindow = Duration(seconds: 6);

const Duration _kHardScanTimeout = Duration(seconds: 15);

const int _kRssiThreshold = -65;

final Guid _kHeartRateServiceUuid = Guid('180d');

/// Manages BLE scanning lifecycle and filters discovered devices.
@Riverpod(keepAlive: true)
class BleScannerNotifier extends _$BleScannerNotifier
    with WidgetsBindingObserver {
  late final BluetoothScannerService _scannerService;

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  Timer? _emptyStateTimer;
  List<ScanResult> _lastRawResults = [];
  bool _filtersEnabled = true;

  /// Whether quality filtering (RSSI threshold and non-empty display name) is active.
  bool get filtersEnabled => _filtersEnabled;

  /// Initializes scanner state and adapter listeners.
  ///
  /// Returns the initial [BleScannerState.idle] state.
  @override
  BleScannerState build() {
    _scannerService = ref.read(bluetoothScannerServiceProvider);
    _adapterStateSubscription = _scannerService.adapterState.listen(
      _onAdapterStateChanged,
      onError: (Object error, StackTrace stack) {
        log.e(
          '[BleScannerNotifier] Adapter state stream error',
          error: error,
          stackTrace: stack,
        );
      },
    );

    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(_cleanup);

    return const BleScannerState.idle();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_scannerService.isScanningNow) {
        log.i('[BleScannerNotifier] App paused — stopping scan.');
        // Fire-and-forget is intentional; lifecycle callback is synchronous.
        // Errors are logged inside stopScan/_cleanup.
        // ignore: discarded_futures
        stopScan();
      }
    }
  }

  /// Initiates an active BLE hardware scan for heart rate sensors.
  ///
  /// Returns a [Future] completing when scan setup finishes or completes with failure state.
  Future<void> startScan() async {
    if (state is AdapterOffScannerState) {
      log.w(
        '[BleScannerNotifier] startScan() skipped — Bluetooth adapter is off.',
      );
      return;
    }

    if (_scannerService.isScanningNow) {
      log.w(
        '[BleScannerNotifier] startScan() skipped — scan already in progress.',
      );
      return;
    }

    log.i('[BleScannerNotifier] Starting Heart Rate scan...');

    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
    _lastRawResults = [];

    state = BleScannerState.scanning(devices: const []);

    _resetEmptyStateTimer();

    _scanResultsSubscription = _scannerService.scanResults.listen(
      _onScanResultsReceived,
      onError: (Object error, StackTrace stack) {
        log.e(
          '[BleScannerNotifier] scanResults stream error',
          error: error,
          stackTrace: stack,
        );
        if (!ref.mounted) return;
        state = BleScannerState.failure(message: error.toString());
      },
    );

    try {
      await _scannerService.startScan(
        withServices: [_kHeartRateServiceUuid],
        timeout: _kHardScanTimeout,
      );
      log.d(
        '[BleScannerNotifier] startScan() returned '
        '(hardware scan window closed).',
      );
    } catch (e) {
      log.e('[BleScannerNotifier] startScan() threw', error: e);
      _cancelEmptyStateTimer();
      await _scanResultsSubscription?.cancel();
      _scanResultsSubscription = null;
      if (!ref.mounted) return;
      state = BleScannerState.failure(message: e.toString());
    }
  }

  /// Halts the active hardware scan and returns the notifier to [BleScannerState.idle].
  ///
  /// Returns a [Future] completing when the scan is stopped.
  Future<void> stopScan() async {
    log.i('[BleScannerNotifier] Stopping scan...');
    _cancelEmptyStateTimer();

    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;

    await _scannerService.stopScan();

    if (!ref.mounted) return;
    if (state is ScanningScannerState || state is EmptyScannerState) {
      state = const BleScannerState.idle();
    }
  }

  /// Resets resources and restarts the hardware BLE scan.
  ///
  /// Returns a [Future] completing when the restart operation finishes.
  Future<void> retry() async {
    log.i('[BleScannerNotifier] retry() — resetting and restarting scan.');
    await stopScan();
    await startScan();
  }

  /// Toggles filtering rules for discovered peripherals and updates current state.
  void toggleFilters() {
    _filtersEnabled = !_filtersEnabled;
    log.d(
      '[BleScannerNotifier] Filters toggled — '
      'filtersEnabled: $_filtersEnabled.',
    );

    if (_lastRawResults.isNotEmpty) {
      _onScanResultsReceived(_lastRawResults);
    }
  }

  void _onAdapterStateChanged(BluetoothAdapterState adapterState) {
    log.i('[BleScannerNotifier] Adapter state → ${adapterState.name}');
    if (!ref.mounted) return;

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
    if (!ref.mounted) return;
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
    log.d(
      '[BleScannerNotifier] Empty-state timer armed '
      '(${_kEmptyStateWindow.inSeconds}s window).',
    );
  }

  void _ensureEmptyStateTimerRunning() {
    if (_emptyStateTimer == null || !_emptyStateTimer!.isActive) {
      _emptyStateTimer = Timer(_kEmptyStateWindow, _onEmptyStateWindowElapsed);
      log.d(
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
    log.d(
      '[BleScannerNotifier] Empty-state window elapsed — '
      'no qualified devices found during active scan.',
    );
    if (!ref.mounted) return;
    if (state is ScanningScannerState) {
      state = const BleScannerState.empty();
    }
  }

  Future<void> _cleanup() async {
    WidgetsBinding.instance.removeObserver(this);
    log.i('[BleScannerNotifier] Disposing — releasing all BLE scan resources.');
    _cancelEmptyStateTimer();

    if (_scannerService.isScanningNow) {
      try {
        await _scannerService.stopScan();
      } catch (e, st) {
        log.w(
          '[BleScannerNotifier] _cleanup stopScan error',
          error: e,
          stackTrace: st,
        );
      }
    }

    await _scanResultsSubscription?.cancel();
    await _adapterStateSubscription?.cancel();
    _scanResultsSubscription = null;
    _adapterStateSubscription = null;
  }
}
