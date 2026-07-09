// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_scanner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(BleScannerNotifier)
final bleScannerProvider = BleScannerNotifierProvider._();

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
final class BleScannerNotifierProvider
    extends $NotifierProvider<BleScannerNotifier, BleScannerState> {
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
  BleScannerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bleScannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bleScannerNotifierHash();

  @$internal
  @override
  BleScannerNotifier create() => BleScannerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BleScannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BleScannerState>(value),
    );
  }
}

String _$bleScannerNotifierHash() =>
    r'1257082b834504d3b1f05f7f03768c32e3f39705';

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

abstract class _$BleScannerNotifier extends $Notifier<BleScannerState> {
  BleScannerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BleScannerState, BleScannerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BleScannerState, BleScannerState>,
              BleScannerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
