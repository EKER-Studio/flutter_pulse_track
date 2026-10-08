import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/dashboard_feature_card.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/saved_sensors_section.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Central dashboard hub for the heart rate monitoring application.
///
/// Displays a reactive list of saved sensor profiles for instant direct-connect,
/// device scanning, and workout history navigation.
class HrHomeView extends StatelessWidget {
  const HrHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.homeTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SavedSensorsSection(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Semantics(
                  button: true,
                  label: l10n.scanForNewSensorButton,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const ExcludeSemantics(
                      child: Icon(
                        Icons.search,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                    label: Text(
                      l10n.scanForNewSensorButton,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => context.push('/scanner'),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: DashboardFeatureCard(
              title: l10n.workoutHistoryTitle,
              icon: Icons.fitness_center,
              description: l10n.workoutHistoryDescription,
              onTap: () => context.push('/history'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
