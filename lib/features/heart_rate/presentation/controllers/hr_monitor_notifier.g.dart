// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_monitor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages heart rate monitor connection, GATT discovery, and live telemetry.

@ProviderFor(HrMonitorNotifier)
final hrMonitorProvider = HrMonitorNotifierProvider._();

/// Manages heart rate monitor connection, GATT discovery, and live telemetry.
final class HrMonitorNotifierProvider
    extends $NotifierProvider<HrMonitorNotifier, MonitorState> {
  /// Manages heart rate monitor connection, GATT discovery, and live telemetry.
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

String _$hrMonitorNotifierHash() => r'c68f12f02b16c370e6a43d57f6b5938db0c2db05';

/// Manages heart rate monitor connection, GATT discovery, and live telemetry.

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
