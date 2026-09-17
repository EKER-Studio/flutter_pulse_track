import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'foreground_task_platform.dart';

/// Foreground service implementation backed by flutter_foreground_task.
class FlutterForegroundTaskPlatform implements ForegroundTaskPlatform {
  @override
  Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout_channel',
        channelName: 'Workout Session',
        channelDescription:
            'Keeps the heart rate monitor alive in the background',
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
      ),
    );
  }

  @override
  Future<bool> isRunningService() => FlutterForegroundTask.isRunningService;

  @override
  Future<void> startService({required void Function() callback}) {
    return FlutterForegroundTask.startService(
      notificationTitle: 'PulseTrack',
      notificationText: 'Recording workout...',
      notificationIcon: const NotificationIcon(metaDataName: 'ic_launcher'),
      callback: callback,
    );
  }

  @override
  Future<void> stopService() => FlutterForegroundTask.stopService();
}
