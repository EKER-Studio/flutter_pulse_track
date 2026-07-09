// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the active Isar database instance globally.
///
/// This provider is declared synchronously to allow zero-latency, reactive DB
/// reads in the UI layer. Because Isar initialization requires async disk access,
/// this provider throws [UnimplementedError] by default.
///
/// **Startup Contract:**
/// The application bootstrap in `main.dart` MUST await `Isar.open()` and
/// override this provider in the root [ProviderScope].

@ProviderFor(isar)
final isarProvider = IsarProvider._();

/// Provides the active Isar database instance globally.
///
/// This provider is declared synchronously to allow zero-latency, reactive DB
/// reads in the UI layer. Because Isar initialization requires async disk access,
/// this provider throws [UnimplementedError] by default.
///
/// **Startup Contract:**
/// The application bootstrap in `main.dart` MUST await `Isar.open()` and
/// override this provider in the root [ProviderScope].

final class IsarProvider extends $FunctionalProvider<Isar, Isar, Isar>
    with $Provider<Isar> {
  /// Provides the active Isar database instance globally.
  ///
  /// This provider is declared synchronously to allow zero-latency, reactive DB
  /// reads in the UI layer. Because Isar initialization requires async disk access,
  /// this provider throws [UnimplementedError] by default.
  ///
  /// **Startup Contract:**
  /// The application bootstrap in `main.dart` MUST await `Isar.open()` and
  /// override this provider in the root [ProviderScope].
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
