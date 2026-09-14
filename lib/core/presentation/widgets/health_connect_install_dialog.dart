import 'package:flutter/material.dart';
import 'package:pulse_track/core/integrations/health/health_service.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Modal dialog prompting the user to download Google Health Connect from Google Play.
class HealthConnectInstallDialog extends StatelessWidget {
  /// Creates a [HealthConnectInstallDialog] instance.
  ///
  /// @param healthService Optional [HealthService] instance for testing.
  /// @param onStoreClicked Optional callback invoked when the user taps install.
  const HealthConnectInstallDialog({
    super.key,
    this.healthService,
    this.onStoreClicked,
  });

  /// Displays the [HealthConnectInstallDialog] in a popup dialog route.
  ///
  /// @param context Build context used to show the dialog.
  /// @param healthService Optional [HealthService] instance for testing.
  static Future<void> show(
    BuildContext context, {
    HealthService? healthService,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => HealthConnectInstallDialog(healthService: healthService),
    );
  }

  /// The health service dependency used to trigger store redirection.
  final HealthService? healthService;

  /// Callback triggered when the store install button is pressed.
  final VoidCallback? onStoreClicked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Text(l10n.healthConnectRequiredTitle),
      content: SizedBox(
        width: 320,
        child: Text(l10n.healthConnectRequiredSubtitle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            onStoreClicked?.call();
            Navigator.pop(context);
            (healthService ?? NativeHealthService.instance)
                .installHealthConnect();
          },
          child: Text(l10n.installFromPlayStore),
        ),
      ],
    );
  }
}
