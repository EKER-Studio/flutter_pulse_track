import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/utils/date_time_formatters.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/widgets/workout_chart_section.dart';
import 'package:pulse_track/features/workout/presentation/widgets/workout_header_card.dart';
import 'package:pulse_track/features/workout/presentation/widgets/workout_summary_grid.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Full-screen details view for a single completed or in-progress workout session.
///
/// Displays a header card with session date and device name, a summary grid
/// showing average BPM, peak BPM, duration, and sample count, and a custom-
/// painted BPM waveform chart colored by heart-rate zones.
///
/// Navigated to from the workout history list via the workout feature route.
class WorkoutDetailsView extends ConsumerWidget {
  /// The workout session whose details are displayed.
  final WorkoutSession session;

  const WorkoutDetailsView({required this.session, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final duration = formatWorkoutDuration(
      session.startTime,
      session.endTime,
      includeSeconds: true,
      inProgressLabel: l10n.inProgress,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.workoutDetailsTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: Semantics(
          button: true,
          label: l10n.workoutDetailsBackHint,
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: l10n.workoutDetailsBackHint,
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: l10n.workoutDetailsExportHint,
            child: IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.share),
              tooltip: l10n.workoutDetailsExportHint,
              onPressed: () async {
                try {
                  await ref
                      .read(workoutExportShareServiceProvider)
                      .exportAndShareSession(
                        session,
                        shareText: l10n.workoutShareSingleText(
                          session.id.toString(),
                        ),
                      );
                } on Object catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.workoutDetailsExportFailed(e.toString()),
                      ),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorkoutHeaderCard(session: session, duration: duration),
                  const SizedBox(height: 24.0),
                  WorkoutSummaryGrid(session: session, duration: duration),
                  const SizedBox(height: 24.0),
                  WorkoutChartSection(session: session),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
