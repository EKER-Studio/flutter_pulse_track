import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/presentation/utils/body_sensor_location_l10n.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/animated_heart_icon.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/live_bpm_chart.dart';
import 'package:pulse_track/features/heart_rate/presentation/widgets/sensor_metric_card.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Telemetry dashboard displayed when a sensor is actively streaming heart rate data.
class HrMonitorConnectedView extends StatelessWidget {
  /// The latest heart rate measurement telemetry.
  final HrMeasurement metric;

  /// Recent heart rate readings (up to 40 samples) for the waveform chart.
  final List<int> recentBpmHistory;

  /// Whether vertical chart scale is auto-zoomed to the min/max of [recentBpmHistory].
  final bool isChartZoomed;

  /// Callback when user toggles chart zoom state.
  final VoidCallback? onToggleChartZoom;

  const HrMonitorConnectedView({
    super.key,
    required this.metric,
    this.recentBpmHistory = const [],
    this.isChartZoomed = false,
    this.onToggleChartZoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBatteryOk =
        metric.batteryLevel != null && metric.batteryLevel! > 20;

    final contactActive = metric.sensorContactActive;
    final String contactValue;
    final IconData contactIcon;
    final Color contactColor;

    if (contactActive == null) {
      contactValue = l10n.skinContactUnsupported;
      contactIcon = Icons.sensors;
      contactColor = AppColors.textSecondary;
    } else if (contactActive) {
      contactValue = l10n.skinContactDetected;
      contactIcon = Icons.check_circle_outline;
      contactColor = AppColors.accentGreen;
    } else {
      contactValue = l10n.skinContactLost;
      contactIcon = Icons.warning_amber_rounded;
      contactColor = AppColors.accentOrange;
    }

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
                ExcludeSemantics(child: AnimatedHeartIcon(bpm: metric.bpm)),
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
          const SizedBox(height: 24),
          LiveBpmChart(
            samples: recentBpmHistory,
            isZoomed: isChartZoomed,
            onToggleZoom: onToggleChartZoom ?? () {},
          ),
          const SizedBox(height: 24),
          SensorMetricCard(
            semanticsLabel: l10n.bodySensorLocationLabel(
              metric.sensorLocation.localizedName(l10n),
            ),
            icon: Icons.accessibility_new,
            title: l10n.bodySensorLocationTitle,
            value: metric.sensorLocation.localizedName(l10n),
          ),
          const SizedBox(height: 16),
          SensorMetricCard(
            semanticsLabel: l10n.sensorBatteryLabel(
              metric.batteryLevel != null
                  ? '${metric.batteryLevel}%'
                  : l10n.batteryNotAvailable,
            ),
            icon: isBatteryOk ? Icons.battery_full : Icons.battery_alert,
            iconColor: isBatteryOk
                ? AppColors.accentGreen
                : AppColors.accentRed,
            title: l10n.sensorBatteryTitle,
            value: metric.batteryLevel != null
                ? '${metric.batteryLevel}%'
                : l10n.batteryNotAvailable,
          ),
          const SizedBox(height: 16),
          SensorMetricCard(
            semanticsLabel: '${l10n.skinContactTitle}: $contactValue',
            icon: contactIcon,
            iconColor: contactColor,
            title: l10n.skinContactTitle,
            value: contactValue,
          ),
          if (metric.energyExpended != null) ...[
            const SizedBox(height: 16),
            SensorMetricCard(
              semanticsLabel:
                  '${l10n.energyExpendedTitle}: ${l10n.energyExpendedUnitKj(metric.energyExpended!)}',
              icon: Icons.local_fire_department,
              iconColor: AppColors.accentOrange,
              title: l10n.energyExpendedTitle,
              value: l10n.energyExpendedUnitKj(metric.energyExpended!),
            ),
          ],
        ],
      ),
    );
  }
}
