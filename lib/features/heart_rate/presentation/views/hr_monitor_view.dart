import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulse_track/l10n/app_localizations.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/utils/body_sensor_location_l10n.dart';

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
    // We defer the execution to the next frame to avoid modifying providers
    // during the build phase.
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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
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
        ConnectedMonitorState(:final measurement) => _buildConnectedState(
          l10n,
          measurement,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(
            child: Icon(
              Icons.bluetooth_disabled,
              size: 80,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.disconnectedStatus,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Semantics(
            button: true,
            label: l10n.returnToScannerButton,
            hint: l10n.returnToScannerHint,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                minimumSize: const Size(180, 48),
              ),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              child: Text(
                l10n.returnToScannerButton,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
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

  Widget _buildConnectedState(AppLocalizations l10n, HrMeasurement metric) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.heartRateLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            label: l10n.heartRateLiveLabel(metric.bpm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.accentRed,
                    size: 44,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${metric.bpm}',
                      style: const TextStyle(
                        fontSize: 84,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.bpmUnit,
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (metric.rrIntervals.isNotEmpty) ...[
            const SizedBox(height: 12),
            Semantics(
              label: l10n.hrMonitorRrIntervalsSemantics(
                metric.rrIntervals
                    .map(
                      (e) =>
                          '${(e * 1000).toStringAsFixed(0)} ${l10n.millisecondsUnit}',
                    )
                    .join(', '),
              ),
              child: Text(
                'R-R: ${metric.rrIntervals.map((e) => '${(e * 1000).toStringAsFixed(0)}ms').join(', ')}',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 48),
          Semantics(
            label: l10n.bodySensorLocationLabel(
              metric.sensorLocation.localizedName(l10n),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.accessibility_new,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bodySensorLocationTitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        metric.sensorLocation.localizedName(l10n),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: l10n.sensorBatteryLabel(
              metric.batteryLevel != null
                  ? '${metric.batteryLevel}%'
                  : l10n.batteryNotAvailable,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      metric.batteryLevel != null && metric.batteryLevel! > 20
                          ? Icons.battery_full
                          : Icons.battery_alert,
                      color:
                          metric.batteryLevel != null &&
                              metric.batteryLevel! > 20
                          ? AppColors.accentGreen
                          : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sensorBatteryTitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        metric.batteryLevel != null
                            ? '${metric.batteryLevel}%'
                            : l10n.batteryNotAvailable,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
    HrMonitorNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentRed.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.accentRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.connectionFailedTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
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
          ),
        ),
      ),
    );
  }
}
