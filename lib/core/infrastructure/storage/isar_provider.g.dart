// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Synchronous provider that returns the initialized Isar database instance.
///
/// Throws [UnimplementedError] if accessed before [main] has completed
/// initialization and overridden the provider in [ProviderScope].

@ProviderFor(isar)
final isarProvider = IsarProvider._();

/// Synchronous provider that returns the initialized Isar database instance.
///
/// Throws [UnimplementedError] if accessed before [main] has completed
/// initialization and overridden the provider in [ProviderScope].

final class IsarProvider extends $FunctionalProvider<Isar, Isar, Isar>
    with $Provider<Isar> {
  /// Synchronous provider that returns the initialized Isar database instance.
  ///
  /// Throws [UnimplementedError] if accessed before [main] has completed
  /// initialization and overridden the provider in [ProviderScope].
  IsarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isarHash();

  @$internal
  @override
  $ProviderElement<Isar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Isar create(Ref ref) {
    return isar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Isar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Isar>(value),
    );
  }
}

String _$isarHash() => r'8bc563a42123b5d8dd481fafe77a6edbd308ed8e';
