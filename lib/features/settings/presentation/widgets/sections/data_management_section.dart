import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/settings/application/settings_providers.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/csv_import_preview_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/wipe_data_dialog.dart';
import 'package:pulse_track/features/workout/application/workout_providers.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Settings section for workout CSV import, export, and complete database reset.
class DataManagementSection extends ConsumerWidget {
  const DataManagementSection({super.key});

  Future<void> _exportWorkouts(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final sessions = await ref.read(watchWorkoutHistoryStreamProvider.future);

    if (sessions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.csvExportEmpty)));
      }
      return;
    }

    try {
      await ref
          .read(workoutExportShareServiceProvider)
          .exportAndShareAllSessions(
            sessions,
            shareText: l10n.workoutShareBulkText(sessions.length.toString()),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.csvExportSuccess)));
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.workoutDetailsExportFailed(e.toString())),
          ),
        );
      }
    }
  }

  Future<void> _importWorkouts(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    try {
      final analysis = await ref
          .read(csvWorkoutImportServiceProvider)
          .pickAndParseCsv();
      if (analysis == null) return;

      if (analysis.validSessions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.csvImportNoValidData)));
        }
        return;
      }

      if (!context.mounted) return;
      final confirmed = await CsvImportPreviewDialog.show(
        context,
        analysis: analysis,
      );
      if (!confirmed) return;

      final repository = ref.read(workoutPersistenceRepositoryProvider);
      final batch = analysis.validSessions
          .map(
            (s) => WorkoutSession(
              id: 0,
              startTime: s.startTime,
              endTime: s.endTime ?? s.startTime,
              avgBpm: s.avgBpm,
              maxBpm: s.maxBpm,
              bpmSamples: s.bpmSamples,
              sensorLocationIndex: s.sensorLocationIndex,
              deviceMacAddress: s.deviceMacAddress,
              deviceName: s.deviceName,
            ),
          )
          .toList();
      await repository.saveWorkoutSessionsBatch(batch);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.csvImportSuccess(analysis.validSessions.length)),
          ),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.workoutDetailsExportFailed(e.toString())),
          ),
        );
      }
    }
  }

  Future<void> _wipeData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WipeDataDialog.show(context);
    if (!confirmed) return;

    final sessions = await ref.read(watchWorkoutHistoryStreamProvider.future);
    final repository = ref.read(workoutPersistenceRepositoryProvider);
    await repository.deleteWorkoutSessions(sessions.map((s) => s.id).toList());

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.wipeDataSuccess)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.settingsSectionData),
        SettingsTile(
          icon: Icons.upload_rounded,
          title: l10n.settingsExportAllWorkouts,
          subtitle: l10n.settingsExportAllWorkoutsSubtitle,
          onTap: () => _exportWorkouts(context, ref),
        ),
        SettingsTile(
          icon: Icons.download_rounded,
          title: l10n.settingsImportWorkouts,
          subtitle: l10n.settingsImportWorkoutsSubtitle,
          onTap: () => _importWorkouts(context, ref),
        ),
        SettingsTile(
          icon: Icons.delete_forever_rounded,
          iconColor: AppColors.errorRed,
          title: l10n.settingsWipeData,
          titleColor: AppColors.errorRed,
          subtitle: l10n.settingsWipeDataSubtitle,
          onTap: () => _wipeData(context, ref),
        ),
      ],
    );
  }
}
