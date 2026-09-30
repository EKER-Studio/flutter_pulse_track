import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_logger.dart';

/// Riverpod provider lifecycle observer for diagnostic logging.
///
/// Dispatches provider additions, updates, disposals, and runtime errors to [log].
final class AppProviderObserver extends ProviderObserver {
  /// Creates an [AppProviderObserver].
  const AppProviderObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    log.d(
      'Provider initialized: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    log.d(
      'Provider updated: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log.d(
      'Provider disposed: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    log.e(
      'Provider failed: ${context.provider.name ?? context.provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
