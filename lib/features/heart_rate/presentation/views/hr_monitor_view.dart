import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ble_heart_rate_monitor/core/presentation/theme/app_colors.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/domain/models/monitor_state.dart';
import 'package:ble_heart_rate_monitor/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';

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
    // Watches [hrMonitorProvider] for reactive updates from the BLE heart rate stream.
    // Delegates to a dedicated builder per [MonitorState] variant to keep the
    // state machine UI clean and exhaustive.
    final state = ref.watch(hrMonitorProvider);
    final notifier = ref.read(hrMonitorProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBackground,
        elevation: 0,
        title: Text(
          widget.deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Show explicit disconnect button only when actively streaming or connecting
          if (state is ConnectedMonitorState ||
              state is ConnectingMonitorState ||
              state is DiscoveringServicesMonitorState)
            TextButton.icon(
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.redAccent,
                size: 18,
              ),
              label: const Text(
                'Disconnect',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                await notifier.disconnect();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: switch (state) {
        DisconnectedMonitorState() => _buildDisconnectedState(context),
        ConnectingMonitorState() => _buildLoadingState(
          'Connecting to device...\nLink-layer handshake in progress',
        ),
        DiscoveringServicesMonitorState() => _buildLoadingState(
          'Discovering Services... Please wait...',
        ),
        ConnectedMonitorState(:final measurement) => _buildConnectedState(
          measurement,
        ),
        FailureMonitorState(:final message) => _buildFailureState(
          context,
          message,
          notifier,
        ),
      },
    );
  }

  /// Renders the UI for a hard-disconnected state with a button to return to the scanner.
  Widget _buildDisconnectedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Disconnected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Return to Scanner',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders a centered loading indicator with a progress message during connection setup.
  Widget _buildLoadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the live telemetry dashboard showing BPM, R-R intervals, sensor location, and battery.
  Widget _buildConnectedState(HrMeasurement metric) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Heart rate',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 44),
              const SizedBox(width: 12),
              Text(
                '${metric.bpm}',
                style: const TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BPM',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (metric.rrIntervals.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'R-R: ${metric.rrIntervals.map((e) => '${(e * 1000).toStringAsFixed(0)}ms').join(', ')}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.accessibility_new, color: Colors.blueAccent),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Body sensor location',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      metric.sensorLocation.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  metric.batteryLevel != null && metric.batteryLevel! > 20
                      ? Icons.battery_full
                      : Icons.battery_alert,
                  color:
                      metric.batteryLevel != null && metric.batteryLevel! > 20
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sensor battery',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      metric.batteryLevel != null
                          ? '${metric.batteryLevel}%'
                          : 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Renders an error card with the failure message and options to retry or go back.
  Widget _buildFailureState(
    BuildContext context,
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
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Connection Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Retry Connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () =>
                      notifier.retry(widget.deviceId, widget.deviceName),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: Colors.grey),
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
