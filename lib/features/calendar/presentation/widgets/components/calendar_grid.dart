import 'package:flutter/material.dart';

import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_day_cell.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// 7-column monthly grid of [CalendarDayCell] instances.
class CalendarGrid extends StatelessWidget {
  /// The month currently focused and displayed.
  final DateTime focusedMonth;

  /// The currently selected date.
  final DateTime selectedDate;

  /// All recorded workout sessions.
  final List<WorkoutSession> sessions;

  /// Callback when a day is selected.
  final ValueChanged<DateTime> onDaySelected;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.sessions,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedMonth.year,
      focusedMonth.month,
    );
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month);

    // Monday-based offset (Monday = 1, Sunday = 7)
    final startingOffset = (firstDayOfMonth.weekday - 1) % 7;
    final totalCells = startingOffset + daysInMonth;

    // Group sessions by day of month
    final Map<int, List<WorkoutSession>> sessionsByDay = {};
    for (final session in sessions) {
      if (session.startTime.year == focusedMonth.year &&
          session.startTime.month == focusedMonth.month) {
        sessionsByDay.putIfAbsent(session.startTime.day, () => []).add(session);
      }
    }

    final now = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        if (index < startingOffset) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - startingOffset + 1;
        final cellDate = DateTime(
          focusedMonth.year,
          focusedMonth.month,
          dayNumber,
        );

        final isSelected =
            cellDate.year == selectedDate.year &&
            cellDate.month == selectedDate.month &&
            cellDate.day == selectedDate.day;

        final isToday =
            cellDate.year == now.year &&
            cellDate.month == now.month &&
            cellDate.day == now.day;

        final daySessions = sessionsByDay[dayNumber] ?? const [];

        return CalendarDayCell(
          date: cellDate,
          isSelected: isSelected,
          isToday: isToday,
          sessions: daySessions,
          onSelected: onDaySelected,
        );
      },
    );
  }
}
