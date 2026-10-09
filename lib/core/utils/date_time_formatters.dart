import 'package:intl/intl.dart' as intl;

import 'package:pulse_track/l10n/app_localizations.dart';

/// Shared date and duration formatting utilities for workout-related views.
///
/// Centralizes formatting logic that was previously duplicated across
/// [WorkoutDetailsView] and [WorkoutHistoryView].

/// Formats a [date] into a relative human-readable string.
///
/// Returns "Today, HH:mm", "Yesterday, HH:mm", or "Weekday, MMM d at HH:mm"
/// depending on how recent the date is relative to the current moment.
String formatRelativeDate(AppLocalizations l10n, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(targetDay).inDays;

  if (difference == 0) {
    return l10n.todayPrefix(intl.DateFormat.Hm().format(date));
  } else if (difference == 1) {
    return l10n.yesterdayPrefix(intl.DateFormat.Hm().format(date));
  } else {
    return l10n.workoutDateAtTime(
      intl.DateFormat.EEEE().format(date),
      intl.DateFormat.Md().format(date),
      intl.DateFormat.Hm().format(date),
    );
  }
}

/// Formats a [date] into an absolute short date string (e.g. "Mon, Oct 13, 2025").
String formatAbsoluteDate(DateTime date) {
  return intl.DateFormat('E, MMM d, y').format(date);
}

/// Formats the elapsed time between [start] and [end] into a compact string.
///
/// Returns "Xh Ym Zs" for the detailed variant (includes seconds) or
/// "Xh Ym" for the compact variant (omits seconds).
/// If [end] is `null` and [inProgressLabel] is provided, returns that label
/// to indicate an active session. Otherwise falls back to [DateTime.now].
String formatWorkoutDuration(
  DateTime start,
  DateTime? end, {
  bool includeSeconds = false,
  String? inProgressLabel,
}) {
  if (end == null && inProgressLabel != null) return inProgressLabel;

  final endTime = end ?? DateTime.now();
  final duration = endTime.difference(start);

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (includeSeconds) {
    final seconds = duration.inSeconds.remainder(60);
    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');
    return parts.join(' ');
  }

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}
