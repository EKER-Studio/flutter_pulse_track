import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Service encapsulating Firebase Analytics events for the application.
class AnalyticsService {
  /// Backing [FirebaseAnalytics] client.
  final FirebaseAnalytics? analytics;

  /// Creates an [AnalyticsService] backed by an optional [analytics] instance.
  ///
  /// If [analytics] is null (e.g. in test suites or when Firebase is uninitialized),
  /// calls are safely ignored without throwing.
  AnalyticsService({this.analytics});

  /// Enables or disables analytics data collection.
  ///
  /// @param enabled True to enable analytics collection; false to disable.
  Future<void> setCollectionEnabled(bool enabled) async {
    await analytics?.setAnalyticsCollectionEnabled(enabled);
  }

  /// Logs when a workout tracking session starts.
  ///
  /// @param deviceId Identifier of the connected heart rate sensor.
  /// @param sport Optional sport or workout type.
  Future<void> logWorkoutStarted({
    required String deviceId,
    String? sport,
  }) async {
    await analytics?.logEvent(
      name: 'workout_started',
      parameters: {'device_id': deviceId, 'sport': ?sport},
    );
  }

  /// Logs when a workout session finishes and is stored.
  ///
  /// @param durationSeconds Total elapsed duration in seconds.
  /// @param avgBpm Average recorded heart rate.
  /// @param maxBpm Peak recorded heart rate.
  Future<void> logWorkoutCompleted({
    required int durationSeconds,
    required int avgBpm,
    required int maxBpm,
  }) async {
    await analytics?.logEvent(
      name: 'workout_completed',
      parameters: {
        'duration_seconds': durationSeconds,
        'avg_bpm': avgBpm,
        'max_bpm': maxBpm,
      },
    );
  }

  /// Logs when a BLE heart rate monitor device is connected.
  ///
  /// @param deviceId MAC address or UUID of the device.
  /// @param deviceName Optional advertising name of the sensor.
  Future<void> logDeviceConnected({
    required String deviceId,
    String? deviceName,
  }) async {
    await analytics?.logEvent(
      name: 'device_connected',
      parameters: {'device_id': deviceId, 'device_name': ?deviceName},
    );
  }

  /// Logs when recorded workouts are exported or shared.
  ///
  /// @param format Export file format (e.g. "csv").
  /// @param sessionCount Number of sessions included in the export.
  Future<void> logExportShared({
    required String format,
    required int sessionCount,
  }) async {
    await analytics?.logEvent(
      name: 'export_shared',
      parameters: {'format': format, 'session_count': sessionCount},
    );
  }
}

/// Provider for the [AnalyticsService] instance.
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  try {
    return AnalyticsService(analytics: FirebaseAnalytics.instance);
  } catch (_) {
    return AnalyticsService();
  }
}

/// Provider for the [FirebaseAnalyticsObserver] navigation observer.
@Riverpod(keepAlive: true)
FirebaseAnalyticsObserver? analyticsObserver(Ref ref) {
  try {
    return FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  } catch (_) {
    return null;
  }
}
