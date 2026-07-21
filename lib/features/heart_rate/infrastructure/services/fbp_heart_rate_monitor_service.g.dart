// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fbp_heart_rate_monitor_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(heartRateMonitorService)
final heartRateMonitorServiceProvider = HeartRateMonitorServiceProvider._();

final class HeartRateMonitorServiceProvider
    extends
        $FunctionalProvider<
          HeartRateMonitorService,
          HeartRateMonitorService,
          HeartRateMonitorService
        >
    with $Provider<HeartRateMonitorService> {
  HeartRateMonitorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heartRateMonitorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heartRateMonitorServiceHash();

  @$internal
  @override
  $ProviderElement<HeartRateMonitorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HeartRateMonitorService create(Ref ref) {
    return heartRateMonitorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HeartRateMonitorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HeartRateMonitorService>(value),
    );
  }
}

String _$heartRateMonitorServiceHash() =>
    r'016a78fda1f182e0716ef69471519f8eb3fe972a';
