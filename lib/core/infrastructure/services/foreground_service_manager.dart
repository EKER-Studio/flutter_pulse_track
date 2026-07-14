import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foreground_service_manager.g.dart';

/// Root-level entry point for the foreground task isolate.
///
/// Must be a top-level function with [pragma] to prevent tree-shaking.
/// Registers [MyTaskHandler] so the isolate knows which handler to invoke.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

/// Task handler that defines the behavior inside the isolate running the
/// foreground service for the heart rate monitor workout session.
class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('MyTaskHandler.onStart: Foreground service started at $timestamp');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    debugPrint('MyTaskHandler.onRepeatEvent: Periodic event at $timestamp');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('MyTaskHandler.onDestroy: Foreground service destroyed (timeout: $isTimeout) at $timestamp');
  }
}

/// Service wrapper encapsulating the configuration and lifecycle of the Android
/// Foreground Service to keep the BLE connection alive in the background.
class ForegroundServiceManager {
  bool _isInitialized = false;

  /// Initializes the foreground task configuration. Must be called before starting.
  Future<void> init() async {
    if (_isInitialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout_channel',
        channelName: 'Workout Session',
        channelDescription: 'Keeps the heart rate monitor alive in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _isInitialized = true;
  }

  /// Configures the foreground task notification and ensures the service is
  /// non-dismissible. Must be called before [startService].
  Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'heart_rate_monitor_channel',
        channelName: 'Heart Rate Monitor',
        channelDescription: 'Recording workout...',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
        allowAutoRestart: true,
      ),
    );
  }

  /// Starts the foreground service and displays the permanent notification.
  Future<void> startService() async {
    await init();

    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Heart Rate Monitor',
      notificationText: 'Recording workout...',
      notificationIcon: const NotificationIcon(
        metaDataName: 'ic_launcher',
      ),
      callback: startCallback,
    );
  }

  /// Stops the foreground service and removes the notification.
  Future<void> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

@riverpod
ForegroundServiceManager foregroundServiceManager(Ref ref) {
  return ForegroundServiceManager();
}
