import 'package:flutter/material.dart';

import 'package:pulse_track/features/settings/presentation/widgets/sections/about_support_section.dart';
import 'package:pulse_track/features/settings/presentation/widgets/sections/appearance_section.dart';
import 'package:pulse_track/features/settings/presentation/widgets/sections/data_management_section.dart';
import 'package:pulse_track/features/settings/presentation/widgets/sections/privacy_diagnostics_section.dart';
import 'package:pulse_track/features/settings/presentation/widgets/sections/security_section.dart';
import 'package:pulse_track/features/settings/presentation/widgets/sections/workout_metrics_section.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Screen providing user controls for appearance, workout metrics,
/// data import/export/wipe operations, and app attribution.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: const [
          AppearanceSection(),
          SizedBox(height: 16),
          WorkoutMetricsSection(),
          SizedBox(height: 16),
          DataManagementSection(),
          SizedBox(height: 16),
          SecuritySection(),
          SizedBox(height: 16),
          PrivacyDiagnosticsSection(),
          SizedBox(height: 16),
          AboutSupportSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
