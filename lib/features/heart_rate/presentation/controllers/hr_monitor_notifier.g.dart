// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_monitor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State machine notifier governing the complete BLE connection and heart rate
/// streaming lifecycle for a single active sensor session.
///
/// ### Lifecycle
///
/// 1. **disconnected** — initial state; no resources held.
/// 2. **connecting** — [BluetoothDevice.connect] is in flight (≤ [_kConnectionTimeout]).
/// 3. **discoveringServices** — link is up; GATT enumeration is in flight
///    (≤ [_kDiscoverServicesTimeout]).  If the timeout fires, a link-layer
///    disconnect is executed and the state transitions to [failure].
/// 4. **connected(measurement)** — GATT notifications are active; state is
///    updated with every decoded [HrMeasurement] packet.
/// 5. **failure(message)** — a non-recoverable error terminated the session.
///    The UI should render a recovery screen with a "Retry" CTA.
///
/// ### Timeout contract
///
/// [discoverServices] is guarded with a **strict 5-second timeout boundary**.
/// When the deadline fires:
///   - [FlutterBluePlus] is instructed to disconnect at the link layer.
///   - The GATT notification subscription is cancelled.
///   - The state transitions to [FailureMonitorState] with a user-facing message.
///   - No dangling resources are left alive.
///
/// ### Disposal
///
/// All stream subscriptions are cancelled in [_cleanup], which is registered
/// with [ref.onDispose]. The active [BluetoothDevice] is disconnected if the
/// notifier is disposed while a session is live.

@ProviderFor(HrMonitorNotifier)
final hrMonitorProvider = HrMonitorNotifierProvider._();

/// State machine notifier governing the complete BLE connection and heart rate
/// streaming lifecycle for a single active sensor session.
///
/// ### Lifecycle
///
/// 1. **disconnected** — initial state; no resources held.
/// 2. **connecting** — [BluetoothDevice.connect] is in flight (≤ [_kConnectionTimeout]).
/// 3. **discoveringServices** — link is up; GATT enumeration is in flight
///    (≤ [_kDiscoverServicesTimeout]).  If the timeout fires, a link-layer
///    disconnect is executed and the state transitions to [failure].
/// 4. **connected(measurement)** — GATT notifications are active; state is
///    updated with every decoded [HrMeasurement] packet.
/// 5. **failure(message)** — a non-recoverable error terminated the session.
///    The UI should render a recovery screen with a "Retry" CTA.
///
/// ### Timeout contract
///
/// [discoverServices] is guarded with a **strict 5-second timeout boundary**.
/// When the deadline fires:
///   - [FlutterBluePlus] is instructed to disconnect at the link layer.
///   - The GATT notification subscription is cancelled.
///   - The state transitions to [FailureMonitorState] with a user-facing message.
///   - No dangling resources are left alive.
///
/// ### Disposal
///
/// All stream subscriptions are cancelled in [_cleanup], which is registered
/// with [ref.onDispose]. The active [BluetoothDevice] is disconnected if the
/// notifier is disposed while a session is live.
final class HrMonitorNotifierProvider
    extends $NotifierProvider<HrMonitorNotifier, MonitorState> {
  /// State machine notifier governing the complete BLE connection and heart rate
  /// streaming lifecycle for a single active sensor session.
  ///
  /// ### Lifecycle
  ///
  /// 1. **disconnected** — initial state; no resources held.
  /// 2. **connecting** — [BluetoothDevice.connect] is in flight (≤ [_kConnectionTimeout]).
  /// 3. **discoveringServices** — link is up; GATT enumeration is in flight
  ///    (≤ [_kDiscoverServicesTimeout]).  If the timeout fires, a link-layer
  ///    disconnect is executed and the state transitions to [failure].
  /// 4. **connected(measurement)** — GATT notifications are active; state is
  ///    updated with every decoded [HrMeasurement] packet.
  /// 5. **failure(message)** — a non-recoverable error terminated the session.
  ///    The UI should render a recovery screen with a "Retry" CTA.
  ///
  /// ### Timeout contract
  ///
  /// [discoverServices] is guarded with a **strict 5-second timeout boundary**.
  /// When the deadline fires:
  ///   - [FlutterBluePlus] is instructed to disconnect at the link layer.
  ///   - The GATT notification subscription is cancelled.
  ///   - The state transitions to [FailureMonitorState] with a user-facing message.
  ///   - No dangling resources are left alive.
  ///
  /// ### Disposal
  ///
  /// All stream subscriptions are cancelled in [_cleanup], which is registered
  /// with [ref.onDispose]. The active [BluetoothDevice] is disconnected if the
  /// notifier is disposed while a session is live.
  HrMonitorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hrMonitorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hrMonitorNotifierHash();

  @$internal
  @override
  HrMonitorNotifier create() => HrMonitorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonitorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonitorState>(value),
    );
  }
}

String _$hrMonitorNotifierHash() => r'4cdb77a144374ff56e65f0e127dedf075b8cb77b';

/// State machine notifier governing the complete BLE connection and heart rate
/// streaming lifecycle for a single active sensor session.
///
/// ### Lifecycle
///
/// 1. **disconnected** — initial state; no resources held.
/// 2. **connecting** — [BluetoothDevice.connect] is in flight (≤ [_kConnectionTimeout]).
/// 3. **discoveringServices** — link is up; GATT enumeration is in flight
///    (≤ [_kDiscoverServicesTimeout]).  If the timeout fires, a link-layer
///    disconnect is executed and the state transitions to [failure].
/// 4. **connected(measurement)** — GATT notifications are active; state is
///    updated with every decoded [HrMeasurement] packet.
/// 5. **failure(message)** — a non-recoverable error terminated the session.
///    The UI should render a recovery screen with a "Retry" CTA.
///
/// ### Timeout contract
///
/// [discoverServices] is guarded with a **strict 5-second timeout boundary**.
/// When the deadline fires:
///   - [FlutterBluePlus] is instructed to disconnect at the link layer.
///   - The GATT notification subscription is cancelled.
///   - The state transitions to [FailureMonitorState] with a user-facing message.
///   - No dangling resources are left alive.
///
/// ### Disposal
///
/// All stream subscriptions are cancelled in [_cleanup], which is registered
/// with [ref.onDispose]. The active [BluetoothDevice] is disconnected if the
/// notifier is disposed while a session is live.

abstract class _$HrMonitorNotifier extends $Notifier<MonitorState> {
  MonitorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MonitorState, MonitorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MonitorState, MonitorState>,
              MonitorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
