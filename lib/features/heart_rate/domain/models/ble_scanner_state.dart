import 'ble_device.dart';

/// Sealed union representing every possible node in the BLE scanner state machine.
///
/// The UI layer performs an exhaustive switch over these states to render the
/// correct screen without any nullable fields, booleans, or stringly-typed flags.
///
/// State transition diagram:
///
/// ```
///  adapterOff ──────────────────────────────────────────────────────────────┐
///     ▲  │ (adapter on)                                                      │
///     │  ▼                                                                   │
///   idle ──(startScan)──▶ scanning ──(0 devices after 6s)──▶ empty          │
///     ▲                      │                                  │            │
///     │                      │                                  │            │
///     └──────(stopScan)───────┘◀──────────(retry)──────────────┘            │
///                                                                            │
///   failure ◀──(unrecoverable scan error)───────────────────────────────────┘
/// ```
sealed class BleScannerState {
  const BleScannerState();

  /// The scanner is powered and ready but no hardware scan is currently running.
  const factory BleScannerState.idle() = _IdleScannerState;

  /// An active hardware scan is in progress; [devices] contains all peripherals
  /// that have passed the currently active quality filters.
  factory BleScannerState.scanning({required List<BleDevice> devices}) =
      _ScanningScannerState;

  /// The 6-second sliding window elapsed without any device passing the active
  /// filters. The user should be prompted to retry or relax the filters.
  const factory BleScannerState.empty() = _EmptyScannerState;

  /// The host Bluetooth adapter is powered off. Scanning is impossible until
  /// the user enables Bluetooth at the system level.
  const factory BleScannerState.adapterOff() = _AdapterOffScannerState;

  /// An unrecoverable error occurred during the scanning operation.
  /// [message] is a human-readable description suitable for UI display.
  const factory BleScannerState.failure({required String message}) =
      _FailureScannerState;
}

// ---------------------------------------------------------------------------
// Concrete state implementations (private to this library).
// ---------------------------------------------------------------------------

final class _IdleScannerState extends BleScannerState {
  const _IdleScannerState();
}

final class _ScanningScannerState extends BleScannerState {
  /// The current snapshot of peripherals that passed all active quality filters.
  final List<BleDevice> devices;

  const _ScanningScannerState({required this.devices});
}

final class _EmptyScannerState extends BleScannerState {
  const _EmptyScannerState();
}

final class _AdapterOffScannerState extends BleScannerState {
  const _AdapterOffScannerState();
}

final class _FailureScannerState extends BleScannerState {
  /// Human-readable error description for the UI recovery screen.
  final String message;

  const _FailureScannerState({required this.message});
}

// ---------------------------------------------------------------------------
// Public type aliases — allows switch pattern matching on concrete types
// without depending on the private implementation classes.
// ---------------------------------------------------------------------------

/// Type alias for the idle state, usable in switch patterns.
typedef IdleScannerState = _IdleScannerState;

/// Type alias for the scanning state, usable in switch patterns.
typedef ScanningScannerState = _ScanningScannerState;

/// Type alias for the empty state, usable in switch patterns.
typedef EmptyScannerState = _EmptyScannerState;

/// Type alias for the adapter-off state, usable in switch patterns.
typedef AdapterOffScannerState = _AdapterOffScannerState;

/// Type alias for the failure state, usable in switch patterns.
typedef FailureScannerState = _FailureScannerState;
