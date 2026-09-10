// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the [AnalyticsService] instance.

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

/// Provider for the [AnalyticsService] instance.

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  /// Provider for the [AnalyticsService] instance.
  AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'c16b0295f5d42cf54db886e0459ca972b8cf8089';

/// Provider for the [FirebaseAnalyticsObserver] navigation observer.

@ProviderFor(analyticsObserver)
final analyticsObserverProvider = AnalyticsObserverProvider._();

/// Provider for the [FirebaseAnalyticsObserver] navigation observer.

final class AnalyticsObserverProvider
    extends
        $FunctionalProvider<
          FirebaseAnalyticsObserver?,
          FirebaseAnalyticsObserver?,
          FirebaseAnalyticsObserver?
        >
    with $Provider<FirebaseAnalyticsObserver?> {
  /// Provider for the [FirebaseAnalyticsObserver] navigation observer.
  AnalyticsObserverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsObserverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsObserverHash();

  @$internal
  @override
  $ProviderElement<FirebaseAnalyticsObserver?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseAnalyticsObserver? create(Ref ref) {
    return analyticsObserver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAnalyticsObserver? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAnalyticsObserver?>(value),
    );
  }
}

String _$analyticsObserverHash() => r'7a4036aa65f47d435541a85f8443345066045bbb';
