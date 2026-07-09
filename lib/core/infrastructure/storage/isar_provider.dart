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
@Riverpod(keepAlive: true)
Isar isar(Ref ref) {
  throw UnimplementedError(
    'isarProvider must be overridden in ProviderScope with an initialized Isar instance.',
  );
}
