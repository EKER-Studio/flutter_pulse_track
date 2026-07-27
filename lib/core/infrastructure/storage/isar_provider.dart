import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_provider.g.dart';

/// Provides the active Isar database instance globally.
///
/// This provider is declared synchronously to allow zero-latency, reactive DB
/// reads in the UI layer. Because Isar initialization requires async disk access,
/// this provider throws [UnimplementedError] by default.
///
/// **Startup Contract:**
/// The application bootstrap in `main.dart` MUST await `Isar.open()` and
/// override this provider in the root [ProviderScope].
///
/// **Safety:**
/// The [keepAlive: true] flag ensures the Isar instance is never disposed by
/// Riverpod's garbage collection, preventing accidental database closure while
/// the app is running. Consumers should never attempt to close the instance.
/// Synchronous provider that returns the initialized Isar database instance using [ref].
///
/// Throws [UnimplementedError] if accessed before `main()` has completed
/// initialization and overridden the provider in [ProviderScope].
@Riverpod(keepAlive: true)
Isar isar(Ref ref) {
  throw UnimplementedError(
    'isarProvider must be overridden in ProviderScope with an initialized Isar instance.',
  );
}
