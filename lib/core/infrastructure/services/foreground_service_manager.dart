import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foreground_service_manager.g.dart';

/// Callback executed when the foreground service starts. Required to be a
/// top-level function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_WorkoutTaskHandler());
}

/// Simple handler to define behavior inside the isolate running the foreground service.
class _WorkoutTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('Foreground Service Task Started.');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('Foreground Service Task Destroyed.');
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

/// Service wrapper encapsulating the configuration and lifecycle of the Android
/// Foreground Service to keep the BLE connection alive in the background.
class ForegroundServiceManager {
  bool _isInitialized = false;

  /// Initializes the foreground task configuration. Must be called before starting.
  Future<void> init() async {
    if (_isInitialized) return;

    if (Platform.isAndroid) {
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
          allowWifiLock: true,
        ),
      );
      _isInitialized = true;
    }
  }

  /// Starts the foreground service and displays the permanent notification.
  Future<void> startService() async {
    if (!Platform.isAndroid) return;
    
    await init();
    
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    if (await FlutterForegroundTask.checkNotificationPermission() ==
        NotificationPermission.denied) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Active Workout Session',
      notificationText: 'Monitoring your heart rate in the background...',
      callback: startCallback,
    );
  }

  /// Stops the foreground service and removes the notification.
  Future<void> stopService() async {
    if (!Platform.isAndroid) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

@riverpod
ForegroundServiceManager foregroundServiceManager(Ref ref) {
  return ForegroundServiceManager();
}
