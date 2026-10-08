// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(foregroundServiceManager)
final foregroundServiceManagerProvider = ForegroundServiceManagerProvider._();

final class ForegroundServiceManagerProvider
    extends
        $FunctionalProvider<
          ForegroundServiceManager,
          ForegroundServiceManager,
          ForegroundServiceManager
        >
    with $Provider<ForegroundServiceManager> {
  ForegroundServiceManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foregroundServiceManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foregroundServiceManagerHash();

  @$internal
  @override
  $ProviderElement<ForegroundServiceManager> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForegroundServiceManager create(Ref ref) {
    return foregroundServiceManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForegroundServiceManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForegroundServiceManager>(value),
    );
  }
}

String _$foregroundServiceManagerHash() =>
    r'e1b6eeb81c5e352d529b071feec1b13e2d6c7a30';

/// Provides the singleton [BiometricService] instance.

@ProviderFor(biometricService)
final biometricServiceProvider = BiometricServiceProvider._();

/// Provides the singleton [BiometricService] instance.

final class BiometricServiceProvider
    extends
        $FunctionalProvider<
          BiometricService,
          BiometricService,
          BiometricService
        >
    with $Provider<BiometricService> {
  /// Provides the singleton [BiometricService] instance.
  BiometricServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricServiceHash();

  @$internal
  @override
  $ProviderElement<BiometricService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BiometricService create(Ref ref) {
    return biometricService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BiometricService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BiometricService>(value),
    );
  }
}

String _$biometricServiceHash() => r'18c7808ad70f63025485fd0181f6424201be9df3';
