import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_grid.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_month_header.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_weekday_header.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

/// Card container hosting month navigation header, weekday labels, and monthly workout grid.
class CalendarMonthCard extends StatelessWidget {
  /// The month currently focused and displayed by the grid.
  final DateTime focusedMonth;

  /// The currently selected day.
  final DateTime selectedDate;

  /// All recorded workout sessions.
  final List<WorkoutSession> sessions;

  /// Callback when navigating to the previous month.
  final VoidCallback onPreviousMonth;

  /// Callback when navigating to the next month.
  final VoidCallback onNextMonth;

  /// Optional callback to jump back to the current date.
  final VoidCallback? onJumpToToday;

  /// Callback when a day in the grid is selected.
  final ValueChanged<DateTime> onDaySelected;

  const CalendarMonthCard({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.sessions,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onJumpToToday,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarMonthHeader(
            focusedMonth: focusedMonth,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onJumpToToday: onJumpToToday,
          ),
          const SizedBox(height: 12),
          const CalendarWeekdayHeader(),
          const SizedBox(height: 8),
          CalendarGrid(
            focusedMonth: focusedMonth,
            selectedDate: selectedDate,
            sessions: sessions,
            onDaySelected: onDaySelected,
          ),
        ],
      ),
    );
  }
}
