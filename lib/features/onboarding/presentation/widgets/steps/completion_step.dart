import 'package:flutter/material.dart';

import 'package:pulse_track/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Final onboarding step confirming setup completion.
class CompletionStep extends StatelessWidget {
  /// Callback to finish onboarding and navigate to the home dashboard.
  final VoidCallback onComplete;

  /// Callback to return to the previous step.
  final VoidCallback onBack;

  const CompletionStep({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.onboardingCompleteTitle,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.onboardingCompleteSubtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      content: Icon(
        Icons.check_circle_outline,
        size: 96,
        color: Theme.of(context).colorScheme.primary,
      ),
      footer: Row(
        children: [
          TextButton(onPressed: onBack, child: Text(l10n.back)),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onComplete,
              child: Text(l10n.getStarted),
            ),
          ),
        ],
      ),
    );
  }
}
