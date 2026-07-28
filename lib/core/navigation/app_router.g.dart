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

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Provides the singleton [GoRouter] instance for the application.
///
/// Routes are defined declaratively and kept in a single location so the
/// navigation graph is easy to audit and extend.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the singleton [GoRouter] instance for the application.
  ///
  /// Routes are defined declaratively and kept in a single location so the
  /// navigation graph is easy to audit and extend.
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

String _$appRouterHash() => r'6b9e1b9b828bc6a775921872000aaf496a5744c9';
