import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ble_heart_rate_monitor/features/workout/domain/models/workout_session.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/usecases/delete_workout_session_usecase.dart';
import 'package:ble_heart_rate_monitor/features/workout/domain/usecases/watch_workout_history_usecase.dart';
import 'package:ble_heart_rate_monitor/features/workout/presentation/views/workout_details_view.dart';

/// Reactive workout history screen that displays every persisted
/// [WorkoutSession], sorted by start time descending, via
/// [watchWorkoutHistoryStreamProvider].
class WorkoutHistoryView extends ConsumerWidget {
  const WorkoutHistoryView({super.key});

  /// Builds the workout history list from [watchWorkoutHistoryStreamProvider].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Workout History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Failed to load workout history: $error',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            itemCount: sessions.length,
            separatorBuilder: (BuildContext _, int index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Dismissible(
                key: Key(session.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                onDismissed: (_) async {
                  try {
                    await ref
                        .read(deleteWorkoutSessionUseCaseProvider)
                        .call(session.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete session: $e')),
                      );
                    }
                  }
                },
                child: _buildWorkoutCard(context, session),
              );
            },
          );
        },
      ),
    );
  }

  /// Renders a centered empty-state message when no workout sessions exist.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 24),
            Text(
              'No workouts recorded yet',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a heart rate monitoring session to see your workout history here.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a tappable card for a single workout session.
  ///
  /// Tapping navigates to [WorkoutDetailsView]. Swiping right dismisses
  /// and deletes the session from Isar.
  Widget _buildWorkoutCard(BuildContext context, WorkoutSession session) {
    final duration = _formatDuration(session.startTime, session.endTime);
    final formattedDate = _formatDate(session.startTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailsView(session: session),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.deviceName.isEmpty
                      ? 'Unknown Sensor'
                      : session.deviceName,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMetricColumn('Avg BPM', '${session.avgBpm}'),
                    const SizedBox(width: 24),
                    _buildMetricColumn('Max BPM', '${session.maxBpm}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a vertical metric pair showing a bold numeric [value] above a [label].
  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }

  /// Returns a relative date string ("Today, HH:mm", "Yesterday…", or "Mon, MMM DD, HH:mm").
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDay).inDays;

    if (difference == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${_getDayOfWeek(date)}, ${_formatMonthDay(date)}, ${_formatTime(date)}';
    }
  }

  /// Returns a 24-hour time string in the form "HH:mm".
  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Returns a compact month-day string (e.g. "Jan 5").
  String _formatMonthDay(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Returns the abbreviated day-of-week name (e.g. "Mon").
  String _getDayOfWeek(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(date.weekday - 1) % 7];
  }

  /// Formats the elapsed time between [start] and [end] into a compact "Xh Ym" string.
  String _formatDuration(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
