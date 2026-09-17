import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../utils/crash_reporter.dart';

/// Manages local notification scheduling for daily workout reminders.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _dailyReminderId = 0;

  void Function(String payload)? onNotificationTapped;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  final String _channelId = 'pulsetrack_reminders';
  String _channelName = 'Workout Reminders';
  String _channelDescription = 'Reminds you to track your heart rate';

  String _title = 'Time to track!';
  String _body = "Don't forget to record your heart rate today.";

  void setLocalizedTexts({
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
  }) {
    _title = title;
    _body = body;
    _channelName = channelName;
    _channelDescription = channelDescription;
    if (_initialized) {
      _updateAndroidChannel();
    }
  }

  Future<void> _updateAndroidChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;
    final channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await androidPlugin.createNotificationChannel(channel);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      );
      await androidPlugin?.createNotificationChannel(channel);

      const androidSettings = AndroidInitializationSettings(
        '@drawable/ic_notification',
      );
      const darwinSettings = DarwinInitializationSettings();

      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload ?? '';
          onNotificationTapped?.call(payload);
        },
      );

      _initialized = true;
    } on Object catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Failed to initialize NotificationService',
      );
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        _title,
        _body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pulsetrack_reminders',
            'Workout Reminders',
            channelDescription: 'Reminds you to track your heart rate',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/history',
      );
    } on Object catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Failed to schedule daily reminder',
      );
    }
  }

  Future<void> cancelDailyReminder() async {
    try {
      await _plugin.cancel(_dailyReminderId);
    } on Object catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Failed to cancel daily reminder',
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
