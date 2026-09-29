// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
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

String _$analyticsServiceHash() => r'2794993d9fe99683b5813ab84fcefabdc9320736';

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

String _$analyticsObserverHash() => r'b6e6be108cb59329c60fbd34be6752b49d1e6ef1';
