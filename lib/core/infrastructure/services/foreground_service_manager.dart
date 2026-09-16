import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:pulse_track/core/infrastructure/services/foreground_task_platform.dart';
import 'package:pulse_track/core/infrastructure/services/flutter_foreground_task_platform.dart';
import 'package:pulse_track/core/utils/app_logger.dart';

/// Root-level entry point for the foreground task isolate.
///
/// Must be a top-level function with [pragma] to prevent tree-shaking.
/// Registers [MyTaskHandler] so the isolate knows which handler to invoke.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

/// Lightweight task handler whose sole responsibility is to keep the main OS
/// process alive via an Android foreground notification. It does NOT manage
/// BLE connections, parse packets, or write to the database.
class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log.i('MyTaskHandler.onStart: Foreground service started at $timestamp');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Intentionally empty — no work needed on repeat events.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    log.i(
      'MyTaskHandler.onDestroy: Foreground service destroyed '
      '(timeout: $isTimeout) at $timestamp',
    );
  }
}

/// Service wrapper encapsulating the configuration and lifecycle of the Android
/// Foreground Service to keep the app process alive in the background.
class ForegroundServiceManager {
  final ForegroundTaskPlatform _platform;
  bool _isInitialized = false;

  /// Creates an instance backed by the given [_platform].
  ///
  /// Defaults to [FlutterForegroundTaskPlatform] when none is provided.
  ForegroundServiceManager({ForegroundTaskPlatform? platform})
    : _platform = platform ?? FlutterForegroundTaskPlatform();

  /// Initializes the foreground task configuration. Must be called before starting.
  Future<void> init() async {
    if (_isInitialized) return;
    await _platform.init();
    _isInitialized = true;
  }

  /// Starts the foreground service and displays the permanent notification.
  Future<void> startService() async {
    await init();

    if (await _platform.isRunningService()) {
      return;
    }

    await _platform.startService(callback: startCallback);
  }

  /// Stops the foreground service and removes the notification.
  ///
  /// Safe against exceptions and guarantees service teardown.
  Future<void> stopService() async {
    try {
      if (await _platform.isRunningService()) {
        await _platform.stopService();
        log.i('[ForegroundServiceManager] Foreground service stopped cleanly.');
      }
    } catch (e, st) {
      log.e(
        '[ForegroundServiceManager] Error while stopping foreground service',
        error: e,
        stackTrace: st,
      );
    }
  }
}
