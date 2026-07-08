import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ble_connection_status.dart';
import '../providers/bluetooth_connection_providers.dart';
import '../providers/heart_rate_providers.dart';

/// Production-ready telemetry monitor view driving reactive Riverpod state updates.
class HrMonitorView extends ConsumerWidget {
  final String deviceId;
  final String deviceName;

  const HrMonitorView({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
      '--- [UI VIEW] Building HrMonitorView for deviceId: $deviceId ---',
    );

    final hrMetricsAsync = ref.watch(heartRateMetricsProvider(deviceId));
    final connectionStateAsync = ref.watch(
      bluetoothConnectionControllerProvider,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          deviceName.isEmpty ? 'HR Monitor' : deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          connectionStateAsync.when(
            data: (status) {
              if (status == BleConnectionStatus.connected) {
                return TextButton.icon(
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
                    await ref
                        .read(bluetoothConnectionControllerProvider.notifier)
                        .disconnect();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              }
              return const _LoadingIndicator();
            },
            loading: () => const _LoadingIndicator(),
            error: (_, _) => const _LoadingIndicator(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: hrMetricsAsync.when(
          data: (metric) => Column(
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
                ),
              ],
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.accessibility_new,
                      color: Colors.blueAccent,
                    ),
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
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      metric.batteryLevel != null && metric.batteryLevel! > 20
                          ? Icons.battery_full
                          : Icons.battery_alert,
                      color:
                          metric.batteryLevel != null &&
                              metric.batteryLevel! > 20
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
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.redAccent),
                SizedBox(height: 16),
                Text(
                  'Waiting for data stream...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      ),
    );
  }
}
