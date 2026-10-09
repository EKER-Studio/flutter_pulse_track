import 'package:flutter/material.dart';

import 'package:pulse_track/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// First introductory step of the onboarding wizard explaining key features.
class WelcomeStep extends StatelessWidget {
  /// Callback to advance to the next onboarding step.
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.onboardingWelcomeTitle,
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.onboardingWelcomeSubtitle,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      content: Column(
        children: [
          _FeatureCard(
            icon: Icons.monitor_heart_outlined,
            title: l10n.onboardingWelcomeHealthSync,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.show_chart_rounded,
            title: l10n.onboardingWelcomeLiveTelemetry,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.history_outlined,
            title: l10n.onboardingWelcomeHistory,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.lock_outline,
            title: l10n.onboardingWelcomePrivacy,
          ),
        ],
      ),
      footer: FilledButton(
        onPressed: onNext,
        child: Text(l10n.onboardingWelcomeStart),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: MergeSemantics(
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
        ),
      ),
    );
  }
}
