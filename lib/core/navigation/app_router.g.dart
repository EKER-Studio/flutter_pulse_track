// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton [GoRouter] instance for the application.
///
/// Routes are defined declaratively and kept in a single location so the
/// navigation graph is easy to audit and extend.
///
/// Settings changes refresh routing via [GoRouter.refreshListenable] instead
/// of `ref.watch`, so toggling a setting (e.g. the theme) re-evaluates
/// redirects without recreating the router and losing navigation state.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides the singleton [GoRouter] instance for the application.
///
/// Routes are defined declaratively and kept in a single location so the
/// navigation graph is easy to audit and extend.
///
/// Settings changes refresh routing via [GoRouter.refreshListenable] instead
/// of `ref.watch`, so toggling a setting (e.g. the theme) re-evaluates
/// redirects without recreating the router and losing navigation state.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the singleton [GoRouter] instance for the application.
  ///
  /// Routes are defined declaratively and kept in a single location so the
  /// navigation graph is easy to audit and extend.
  ///
  /// Settings changes refresh routing via [GoRouter.refreshListenable] instead
  /// of `ref.watch`, so toggling a setting (e.g. the theme) re-evaluates
  /// redirects without recreating the router and losing navigation state.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'b57a823c55abdcf304aa688ca6148eba6eae7b61';
