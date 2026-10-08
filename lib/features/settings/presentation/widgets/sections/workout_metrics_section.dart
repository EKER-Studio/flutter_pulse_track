import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse_track/features/settings/presentation/controllers/app_settings_notifier.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/max_hr_selection_dialog.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_section_header.dart';
import 'package:pulse_track/features/settings/presentation/widgets/components/settings_tile.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Settings section for workout metric thresholds (e.g. default maximum heart rate).
class WorkoutMetricsSection extends ConsumerWidget {
  const WorkoutMetricsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.settingsSectionWorkout),
        SettingsTile(
          icon: Icons.favorite_outline_rounded,
          title: l10n.settingsDefaultMaxHr,
          subtitle: l10n.settingsDefaultMaxHrSubtitle(settings.defaultMaxHr),
          onTap: () => MaxHrSelectionDialog.show(
            context,
            currentMaxHr: settings.defaultMaxHr,
            onConfirmed: (maxHr) =>
                ref.read(appSettingsProvider.notifier).updateMaxHr(maxHr),
          ),
        ),
      ],
    );
  }
}
