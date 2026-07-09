// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foreground_service_manager.dart';

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
        isAutoDispose: true,
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
    r'ea17081dd6c5ba8a1670e2f3d7fb0bd95d39e234';
