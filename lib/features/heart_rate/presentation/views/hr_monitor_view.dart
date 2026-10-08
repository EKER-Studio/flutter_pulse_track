import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/core/presentation/widgets/failure_card.dart';
import 'package:pulse_track/core/presentation/widgets/status_state_view.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/hr_monitor_connected_view.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Telemetry dashboard and BLE connection lifecycle view.
///
/// Implements an exhaustive state machine UI reacting to [MonitorState]
/// emitted by [hrMonitorProvider].
class HrMonitorView extends ConsumerStatefulWidget {
  /// Unique BLE identifier of the target heart rate sensor.
  final String deviceId;

  /// Human-readable display name of the target heart rate sensor.
  final String deviceName;

  const HrMonitorView({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  ConsumerState<HrMonitorView> createState() => _HrMonitorViewState();
}

class _HrMonitorViewState extends ConsumerState<HrMonitorView> {
  @override
  void initState() {
    super.initState();
    // Initiate the connection sequence as soon as the view is mounted.
    // Defer execution to the next frame to avoid modifying providers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(hrMonitorProvider.notifier)
          .connect(widget.deviceId, widget.deviceName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hrMonitorProvider);
    final notifier = ref.read(hrMonitorProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.deviceName,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (state is ConnectedMonitorState ||
              state is ConnectingMonitorState ||
              state is DiscoveringServicesMonitorState)
            Semantics(
              button: true,
              label: l10n.disconnectButton,
              hint: l10n.disconnectHint(widget.deviceName),
              child: TextButton.icon(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                icon: const ExcludeSemantics(
                  child: Icon(
                    Icons.power_settings_new,
                    color: AppColors.accentRed,
                    size: 18,
                  ),
                ),
                label: Text(
                  l10n.disconnectButton,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  await notifier.disconnect();
                  if (!context.mounted) return;
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
        ],
      ),
      body: switch (state) {
        DisconnectedMonitorState() => _buildDisconnectedState(context, l10n),
        ConnectingMonitorState() => _buildLoadingState(l10n.connectingMessage),
        DiscoveringServicesMonitorState() => _buildLoadingState(
          l10n.discoveringServicesMessage,
        ),
        ConnectedMonitorState(:final measurement) => HrMonitorConnectedView(
          metric: measurement,
        ),
        FailureMonitorState(:final message) => _buildFailureState(
          context,
          l10n,
          message,
          notifier,
        ),
      },
    );
  }

  Widget _buildDisconnectedState(BuildContext context, AppLocalizations l10n) {
    return StatusStateView(
      icon: Icons.bluetooth_disabled,
      title: l10n.disconnectedStatus,
      action: Semantics(
        button: true,
        label: l10n.returnToScannerButton,
        hint: l10n.returnToScannerHint,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            minimumSize: const Size(180, 48),
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          child: Text(
            l10n.returnToScannerButton,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Semantics(
          liveRegion: true,
          label: message,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.accentBlue,
                strokeWidth: 3,
              ),
              const SizedBox(height: 32),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFailureState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
    HrMonitorNotifier notifier,
  ) {
    return FailureCard(
      title: l10n.connectionFailedTitle,
      message: message,
      actions: [
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: l10n.retryConnectionButton,
            hint: l10n.retryConnectionHint,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const ExcludeSemantics(
                child: Icon(Icons.refresh, color: AppColors.textPrimary),
              ),
              label: Text(
                l10n.retryConnectionButton,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () =>
                  notifier.retry(widget.deviceId, widget.deviceName),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: l10n.goBackButton,
            hint: l10n.goBackHint,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(48, 48),
              ),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              child: Text(
                l10n.goBackButton,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
