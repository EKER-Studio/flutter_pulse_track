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
