import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'foreground_task_platform.dart';

class FlutterForegroundTaskPlatform implements ForegroundTaskPlatform {
  @override
  Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout_channel',
        channelName: 'Workout Session',
        channelDescription:
            'Keeps the heart rate monitor alive in the background',
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
  }

  @override
  Future<bool> isRunningService() => FlutterForegroundTask.isRunningService;

  @override
  Future<void> startService({required void Function() callback}) {
    return FlutterForegroundTask.startService(
      notificationTitle: 'Heart Rate Monitor',
      notificationText: 'Recording workout...',
      notificationIcon: const NotificationIcon(metaDataName: 'ic_launcher'),
      callback: callback,
    );
  }

  @override
  Future<void> stopService() => FlutterForegroundTask.stopService();
}
