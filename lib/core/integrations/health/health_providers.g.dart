// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthService)
final healthServiceProvider = HealthServiceProvider._();

final class HealthServiceProvider
    extends $FunctionalProvider<HealthService, HealthService, HealthService>
    with $Provider<HealthService> {
  HealthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthServiceHash();

  @$internal
  @override
  $ProviderElement<HealthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HealthService create(Ref ref) {
    return healthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthService>(value),
    );
  }
}

String _$healthServiceHash() => r'dfdad5ff88ed423f6d74fc485ae3fd63e023a30a';

@ProviderFor(healthSyncCoordinator)
final healthSyncCoordinatorProvider = HealthSyncCoordinatorProvider._();

final class HealthSyncCoordinatorProvider
    extends
        $FunctionalProvider<
          HealthSyncCoordinator,
          HealthSyncCoordinator,
          HealthSyncCoordinator
        >
    with $Provider<HealthSyncCoordinator> {
  HealthSyncCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthSyncCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthSyncCoordinatorHash();

  @$internal
  @override
  $ProviderElement<HealthSyncCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthSyncCoordinator create(Ref ref) {
    return healthSyncCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthSyncCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthSyncCoordinator>(value),
    );
  }
}

String _$healthSyncCoordinatorHash() =>
    r'6675216d4c94d2354dbcb41e11fb3def915d46dd';
