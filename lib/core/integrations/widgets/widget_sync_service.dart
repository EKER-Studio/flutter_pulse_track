import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../utils/crash_reporter.dart';
import '../../../features/workout/domain/models/workout_session.dart';

/// Synchronizes the latest workout data with native home screen widgets on iOS (WidgetKit) and Android (AppWidgetProvider).
class WidgetSyncService {
  static const String appGroupId = 'group.com.ekerstudio.pulsetrack';
  static const String androidWidgetName = 'PulseTrackAppWidgetProvider';
  static const String iOSWidgetName = 'PulseTrackWidget';

  static WidgetSyncService instance = const WidgetSyncService();

  const WidgetSyncService();

  /// Initializes the widget integration and configures the App Group identifier.
  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Failed to initialize WidgetSyncService',
        fatal: false,
      );
    }
  }

  /// Pushes the latest workout data to native widget storage.
  Future<void> updateWidgetData({
    required List<WorkoutSession> sessions,
  }) async {
    try {
      if (sessions.isEmpty) {
        await HomeWidget.saveWidgetData<bool>('has_data', false);
        await HomeWidget.saveWidgetData<String>('last_workout_date', '');
        await HomeWidget.saveWidgetData<String>('avg_bpm', '--');
        await HomeWidget.saveWidgetData<String>('max_bpm', '--');
        await HomeWidget.saveWidgetData<String>('duration', '--');
        await HomeWidget.saveWidgetData<String>('device_name', '');
        await HomeWidget.saveWidgetData<int>('samples_count', 0);
      } else {
        final sorted = sessions.toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
        final latest = sorted.last;
        final dateStr = DateFormat('dd MMM, HH:mm').format(latest.startTime);
        final endTime = latest.endTime;
        final duration = endTime != null
            ? endTime.difference(latest.startTime)
            : Duration.zero;
        final durationStr = _formatDuration(duration);

        await HomeWidget.saveWidgetData<bool>('has_data', true);
        await HomeWidget.saveWidgetData<String>('last_workout_date', dateStr);
        await HomeWidget.saveWidgetData<String>('avg_bpm', '${latest.avgBpm}');
        await HomeWidget.saveWidgetData<String>('max_bpm', '${latest.maxBpm}');
        await HomeWidget.saveWidgetData<String>('duration', durationStr);
        await HomeWidget.saveWidgetData<String>(
          'device_name',
          latest.deviceName,
        );
        await HomeWidget.saveWidgetData<int>(
          'samples_count',
          latest.bpmSamples.length,
        );
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: 'Failed to update widget data',
        fatal: false,
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
