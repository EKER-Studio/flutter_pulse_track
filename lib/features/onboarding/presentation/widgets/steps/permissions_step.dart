import 'package:flutter/material.dart';

import 'package:pulse_track/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Second onboarding step describing required hardware and system permissions.
class PermissionsStep extends StatelessWidget {
  /// Callback to advance to the next onboarding step.
  final VoidCallback onNext;

  /// Callback to return to the previous step.
  final VoidCallback onBack;

  const PermissionsStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingStepLayout(
      titleWidget: Text(
        l10n.onboardingPermissionsTitle,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      subtitleWidget: Text(
        l10n.onboardingPermissionsSubtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        children: [
          _PermissionTile(
            icon: Icons.bluetooth,
            title: l10n.permissionBluetoothTitle,
            subtitle: l10n.permissionBluetoothSubtitle,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.notifications_outlined,
            title: l10n.permissionNotificationsTitle,
            subtitle: l10n.permissionNotificationsSubtitle,
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.favorite_outline,
            title: l10n.permissionHealthTitle,
            subtitle: l10n.permissionHealthSubtitle,
          ),
        ],
      ),
      footer: Row(
        children: [
          TextButton(onPressed: onBack, child: Text(l10n.back)),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(onPressed: onNext, child: Text(l10n.next)),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
