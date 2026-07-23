abstract class ForegroundTaskPlatform {
  Future<void> init();
  Future<bool> isRunningService();
  Future<void> startService({required void Function() callback});
  Future<void> stopService();
}