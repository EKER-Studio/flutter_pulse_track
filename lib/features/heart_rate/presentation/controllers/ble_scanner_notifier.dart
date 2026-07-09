import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/ble_device.dart';
import '../../domain/models/ble_scanner_state.dart';

part 'ble_scanner_notifier.g.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Duration of the "empty state" sliding window. If no peripheral passes the
/// active quality filters within this period after a scan starts, the notifier
/// transitions to [BleScannerState.empty] so the UI can offer a clear recovery
/// action rather than leaving the user staring at an indefinite spinner.
const Duration _kEmptyStateWindow = Duration(seconds: 6);

/// Hardware-level hard timeout passed to [FlutterBluePlus.startScan]. Acts as
/// an absolute upper bound on scan duration independent of the empty-state timer.
const Duration _kHardScanTimeout = Duration(seconds: 15);

/// Minimum RSSI (dBm) for a device to pass the "Nearby" proximity filter.
/// Devices weaker than this threshold are considered out of reliable operating
/// range for a stable BLE connection and are excluded from results.
const int _kRssiThreshold = -65;

/// Heart Rate Service UUID as assigned by the Bluetooth SIG (0x180D).
/// Passed to [FlutterBluePlus.startScan] so the hardware radio only surfaces
/// peripherals that explicitly advertise the heart rate service.
final Guid _kHeartRateServiceUuid = Guid('180d');

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// State machine notifier governing the complete BLE scanner lifecycle.
///
/// This notifier owns all hardware interactions related to device discovery:
///
/// - It reactively monitors [FlutterBluePlus.adapterState] and immediately
///   transitions to [BleScannerState.adapterOff] if Bluetooth is disabled,
///   preempting any other state.
/// - It applies two composable device-quality filters controlled by
///   [toggleFilters]:
///     • **Names filter** — discards peripherals with an empty platform name.
///     • **Nearby filter** — discards peripherals with RSSI < [_kRssiThreshold].
/// - It arms a [_kEmptyStateWindow] sliding-window [Timer] on scan start.
///   If no peripheral passes the active filters within that window, the state
///   transitions to [BleScannerState.empty] so the UI shows a clear prompt.
/// - [retry] and [toggleFilters] provide clean intent-based recovery actions
///   for the UI without exposing raw BLE primitives.
///
/// Lifecycle: created on first use, disposed with the enclosing [ProviderScope].
/// All stream subscriptions and timers are cancelled in [_cleanup].
@riverpod
class BleScannerNotifier extends _$BleScannerNotifier {
  // --- Stream subscriptions ---------------------------------------------------

  /// Subscription to [FlutterBluePlus.adapterState]. Lives for the full
  /// lifetime of this notifier so adapter power changes are never missed.
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  /// Subscription to [FlutterBluePlus.scanResults]. Created on [startScan] and
  /// cancelled on [stopScan] or when the notifier is disposed.
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  // --- Timer ------------------------------------------------------------------

  /// Fires [_onEmptyStateWindowElapsed] if no qualified device is discovered
  /// within [_kEmptyStateWindow] of a scan starting. Cancelled as soon as
  /// at least one qualified device appears.
  Timer? _emptyStateTimer;

  // --- Local state ------------------------------------------------------------

  /// The raw, unfiltered scan results from the last [FlutterBluePlus.scanResults]
  /// emission. Cached so [toggleFilters] can immediately re-apply the new filter
  /// configuration without waiting for the next BLE advertisement packet.
  List<ScanResult> _lastRawResults = [];

  /// Controls whether the Names and Nearby quality filters are applied to
  /// incoming scan results. When false, all discovered peripherals — including
  /// unnamed and distant ones — are passed through to state.
  bool _filtersEnabled = true;

  // ---------------------------------------------------------------------------
  // Riverpod build — initialise subscriptions and return starting state
  // ---------------------------------------------------------------------------

  @override
  BleScannerState build() {
    // Begin watching the adapter state immediately so we never miss a power-off
    // event, even if startScan() has not been called yet.
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      _onAdapterStateChanged,
      onError: (Object error, StackTrace stack) {
        debugPrint(
          '[BleScannerNotifier] Adapter state stream error: $error\n$stack',
        );
      },
    );

    // Register cleanup so all resources are released when Riverpod disposes
    // this notifier (e.g., on ProviderScope disposal or hot restart).
    ref.onDispose(() => _cleanup());

    return const BleScannerState.idle();
  }

  // ---------------------------------------------------------------------------
  // Public interface — intent-based API for the UI layer
  // ---------------------------------------------------------------------------

  /// Starts a BLE hardware scan restricted to the Heart Rate Service (0x180D).
  ///
  /// This method is idempotent: a second call while a scan is already running
  /// is safely ignored. On success the state transitions to
  /// [BleScannerState.scanning] with an initially empty device list and the
  /// [_kEmptyStateWindow] timer is armed.
  ///
  /// If the Bluetooth adapter is off, the method logs a warning and returns
  /// without changing state. If [FlutterBluePlus.startScan] throws, the notifier
  /// transitions to [BleScannerState.failure] with the error message.
  Future<void> startScan() async {
    if (state is AdapterOffScannerState) {
      debugPrint(
        '[BleScannerNotifier] startScan() skipped — Bluetooth adapter is off.',
      );
      return;
    }

    if (FlutterBluePlus.isScanningNow) {
      debugPrint(
        '[BleScannerNotifier] startScan() skipped — scan already in progress.',
      );
      return;
    }

    debugPrint('[BleScannerNotifier] Starting Heart Rate scan...');

    // Cancel any stale results subscription from a previous scan before
    // creating a new one to avoid receiving events on a dead subscription.
    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
    _lastRawResults = [];

    // Transition immediately so the UI can show a scanning indicator.
    state = BleScannerState.scanning(devices: const []);

    // Arm the empty-state timer from this exact moment. If no qualified device
    // appears within [_kEmptyStateWindow], we transition to [empty].
    _resetEmptyStateTimer();

    // Subscribe to scan results before calling startScan() to guarantee no
    // advertisement packets are lost in the gap between the two calls.
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      _onScanResultsReceived,
      onError: (Object error, StackTrace stack) {
        debugPrint(
          '[BleScannerNotifier] scanResults stream error: $error\n$stack',
        );
        state = BleScannerState.failure(message: error.toString());
      },
    );

    try {
      await FlutterBluePlus.startScan(
        withServices: [_kHeartRateServiceUuid],
        timeout: _kHardScanTimeout,
      );
      debugPrint(
        '[BleScannerNotifier] FlutterBluePlus.startScan() returned '
        '(hardware scan window closed).',
      );
    } catch (e) {
      debugPrint(
        '[BleScannerNotifier] FlutterBluePlus.startScan() threw: $e',
      );
      _cancelEmptyStateTimer();
      await _scanResultsSubscription?.cancel();
      _scanResultsSubscription = null;
      state = BleScannerState.failure(message: e.toString());
    }
  }

  /// Halts the active hardware scan and transitions to [BleScannerState.idle].
  ///
  /// Safe to call when no scan is running — all cancellations are guarded.
  /// Does not transition to idle if the current state is [adapterOff] or
  /// [failure], preserving more descriptive error information in those cases.
  Future<void> stopScan() async {
    debugPrint('[BleScannerNotifier] Stopping scan...');
    _cancelEmptyStateTimer();

    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    // Only reset to idle from normal scanning states; do not clobber a more
    // descriptive adapter-off or failure state.
    if (state is ScanningScannerState || state is EmptyScannerState) {
      state = const BleScannerState.idle();
    }
  }

  /// Cancels any active scan, resets to idle, then immediately launches a fresh
  /// scan. This is the primary recovery action for [EmptyScannerState] and
  /// [FailureScannerState] — the UI "Retry" CTA should call this method.
  Future<void> retry() async {
    debugPrint('[BleScannerNotifier] retry() — resetting and restarting scan.');
    await stopScan();
    await startScan();
  }

  /// Toggles the device-quality filters (Names + Nearby) on or off.
  ///
  /// When filters are **enabled** (default), only devices with a non-empty
  /// platform name and an RSSI ≥ [_kRssiThreshold] are surfaced in state.
  ///
  /// When filters are **disabled**, all discovered peripherals pass through.
  /// This is useful when a user needs to connect to a device that is slightly
  /// out of the preferred range or has not yet broadcast a name.
  ///
  /// The new filter configuration is applied immediately to [_lastRawResults]
  /// so the UI updates without waiting for the next BLE advertisement.
  void toggleFilters() {
    _filtersEnabled = !_filtersEnabled;
    debugPrint(
      '[BleScannerNotifier] Filters toggled — '
      'filtersEnabled: $_filtersEnabled.',
    );

    // Re-process the cached results immediately so the state change is visible
    // to the user the instant they toggle the switch.
    if (_lastRawResults.isNotEmpty) {
      _onScanResultsReceived(_lastRawResults);
    }
  }

  // ---------------------------------------------------------------------------
  // Private — adapter state handler
  // ---------------------------------------------------------------------------

  /// Reacts to [BluetoothAdapterState] changes emitted by
  /// [FlutterBluePlus.adapterState]. A power-off event immediately overrides
  /// any other state and cancels all in-flight scan operations.
  void _onAdapterStateChanged(BluetoothAdapterState adapterState) {
    debugPrint(
      '[BleScannerNotifier] Adapter state → ${adapterState.name}',
    );

    switch (adapterState) {
      case BluetoothAdapterState.off:
        // Cancel everything and surface the adapter constraint to the UI.
        _cancelEmptyStateTimer();
        _scanResultsSubscription?.cancel();
        _scanResultsSubscription = null;
        _lastRawResults = [];
        state = const BleScannerState.adapterOff();

      case BluetoothAdapterState.on:
        // Recover to idle only if we were previously in the adapter-off state.
        // This allows the user to retry after re-enabling Bluetooth without
        // having to restart the app.
        if (state is AdapterOffScannerState) {
          state = const BleScannerState.idle();
        }

      default:
        // Transitional states (turningOn, turningOff, etc.) — no action needed;
        // the next terminal state will trigger the appropriate transition.
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Private — scan results handler
  // ---------------------------------------------------------------------------

  /// Processes a raw [ScanResult] list emitted by [FlutterBluePlus.scanResults],
  /// applies active quality filters, de-duplicates by device ID (keeping the
  /// most recently received entry), and updates the notifier state.
  void _onScanResultsReceived(List<ScanResult> results) {
    // Cache the raw results for immediate re-processing when filters are toggled.
    _lastRawResults = results;

    final Map<String, BleDevice> uniqueDevices = {};

    for (final ScanResult result in results) {
      final String deviceId = result.device.remoteId.str;
      final String platformName = result.device.platformName;
      final int rssi = result.rssi;

      if (_filtersEnabled) {
        // Names filter: peripherals with no broadcast name are typically not
        // connectable consumer devices and are dropped to reduce UI noise.
        if (platformName.isEmpty) continue;

        // Nearby filter: peripherals weaker than the threshold are too far
        // away for a reliable GATT connection and are dropped from results.
        if (rssi < _kRssiThreshold) continue;
      }

      // Last-write-wins for duplicate IDs so the entry always reflects the
      // freshest advertisement data (strongest signal or latest name update).
      uniqueDevices[deviceId] = BleDevice(
        id: deviceId,
        name: platformName.isEmpty ? 'Unknown Device' : platformName,
        rssi: rssi,
      );
    }

    final List<BleDevice> qualifiedDevices =
        uniqueDevices.values.toList(growable: false);

    if (qualifiedDevices.isNotEmpty) {
      // At least one device passed the filters — cancel the empty-state timer
      // because the scan is actively yielding useful results.
      _cancelEmptyStateTimer();
      state = BleScannerState.scanning(devices: qualifiedDevices);
    } else {
      // No qualified devices yet. Ensure the timer is running so we transition
      // to [empty] if this persists for the full [_kEmptyStateWindow].
      //
      // Re-arm only if we are still in a scanning state; if the adapter went
      // off in parallel, that state takes precedence.
      if (state is ScanningScannerState) {
        _ensureEmptyStateTimerRunning();
        // Update the scanning state with the empty list so the UI reflects
        // that scanning is active but producing no qualified results yet.
        state = BleScannerState.scanning(devices: const []);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Private — empty-state timer management
  // ---------------------------------------------------------------------------

  /// Cancels any running timer and creates a fresh one from this instant.
  /// Called at the start of every new scan to reset the sliding window.
  void _resetEmptyStateTimer() {
    _cancelEmptyStateTimer();
    _emptyStateTimer = Timer(_kEmptyStateWindow, _onEmptyStateWindowElapsed);
    debugPrint(
      '[BleScannerNotifier] Empty-state timer armed '
      '(${_kEmptyStateWindow.inSeconds}s window).',
    );
  }

  /// Creates a timer only when one is not already active.
  /// Used to re-arm after the results stream delivers an empty filtered list
  /// following a filter toggle, without resetting an already-running window.
  void _ensureEmptyStateTimerRunning() {
    if (_emptyStateTimer == null || !_emptyStateTimer!.isActive) {
      _emptyStateTimer = Timer(_kEmptyStateWindow, _onEmptyStateWindowElapsed);
      debugPrint(
        '[BleScannerNotifier] Empty-state timer re-armed '
        '(${_kEmptyStateWindow.inSeconds}s window).',
      );
    }
  }

  /// Cancels the timer and nulls the reference. Safe to call when no timer is
  /// running — the null-aware operator guards against the case.
  void _cancelEmptyStateTimer() {
    _emptyStateTimer?.cancel();
    _emptyStateTimer = null;
  }

  /// Called when [_kEmptyStateWindow] elapses without a single qualified device.
  ///
  /// Transitions the state to [BleScannerState.empty] only if we are still in
  /// a scanning state; this guards against a race where the adapter powered off
  /// (transitioning to [adapterOff]) between the timer arming and firing.
  void _onEmptyStateWindowElapsed() {
    debugPrint(
      '[BleScannerNotifier] Empty-state window elapsed — '
      'no qualified devices found during active scan.',
    );
    if (state is ScanningScannerState) {
      state = const BleScannerState.empty();
    }
  }

  // ---------------------------------------------------------------------------
  // Private — disposal
  // ---------------------------------------------------------------------------

  /// Cancels all active subscriptions and timers. Called synchronously by
  /// Riverpod's [ref.onDispose] callback when this notifier is torn down.
  void _cleanup() {
    debugPrint(
      '[BleScannerNotifier] Disposing — releasing all BLE scan resources.',
    );
    _cancelEmptyStateTimer();
    _scanResultsSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription = null;
    _adapterStateSubscription = null;

    // Best-effort hardware stop: if the notifier is disposed mid-scan we must
    // release the radio to prevent battery drain in the background.
    if (FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }
  }
}
