// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_monitor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HrMonitorNotifier)
final hrMonitorProvider = HrMonitorNotifierProvider._();

final class HrMonitorNotifierProvider
    extends $NotifierProvider<HrMonitorNotifier, MonitorState> {
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

String _$hrMonitorNotifierHash() => r'70f6b1e19a67a906b36b7781dfaea14d4f3ad07e';

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
