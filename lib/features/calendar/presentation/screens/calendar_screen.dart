import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/widgets/clamped_layout.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/components/calendar_shimmer_skeleton.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/sections/calendar_month_card.dart';
import 'package:pulse_track/features/calendar/presentation/widgets/sections/calendar_selected_day_section.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Screen presenting workout sessions in an interactive monthly calendar view.
class CalendarScreen extends ConsumerStatefulWidget {
  /// Optional initial date to focus and select when opening the screen.
  final DateTime? initialDate;

  const CalendarScreen({super.key, this.initialDate});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = widget.initialDate ?? today;
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _selectedDate = today;
      _focusedMonth = DateTime(today.year, today.month);
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (date.year != _focusedMonth.year ||
          date.month != _focusedMonth.month) {
        _focusedMonth = DateTime(date.year, date.month);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(watchWorkoutHistoryStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.calendarTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accentBlue,
        onRefresh: () async {
          ref.invalidate(watchWorkoutHistoryStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ClampedLayout(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: historyAsync.when(
              loading: () => const CalendarShimmerSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    err.toString(),
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ),
              data: (sessions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarMonthCard(
                      focusedMonth: _focusedMonth,
                      selectedDate: _selectedDate,
                      sessions: sessions,
                      onPreviousMonth: _previousMonth,
                      onNextMonth: _nextMonth,
                      onJumpToToday: _jumpToToday,
                      onDaySelected: _onDaySelected,
                    ),
                    const SizedBox(height: 20),
                    CalendarSelectedDaySection(
                      selectedDate: _selectedDate,
                      sessions: sessions,
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
