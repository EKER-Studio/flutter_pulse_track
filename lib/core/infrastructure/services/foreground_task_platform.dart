/// Abstract platform for managing a foreground service lifecycle.
abstract class ForegroundTaskPlatform {
  /// Initializes platform-specific foreground service configuration.
  Future<void> init();

  /// Returns true if the foreground service is currently running.
  Future<bool> isRunningService();

  /// Starts the foreground service with the given [callback].
  Future<void> startService({required void Function() callback});

  /// Stops the currently running foreground service.
  Future<void> stopService();
}
