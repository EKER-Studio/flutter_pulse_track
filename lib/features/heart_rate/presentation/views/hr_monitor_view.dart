import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bluetooth_connection_providers.dart';
import '../providers/heart_rate_providers.dart';

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
    print('--- [UI VIEW] Building HrMonitorView for deviceId: $deviceId ---');

    final connectionStatus = ref.watch(bleConnectionStatusProvider);
    print('--- [UI VIEW] Connection Status: $connectionStatus ---');

    final hrMetricsAsync = ref.watch(heartRateMetricsProvider(deviceId));
    print('--- [UI VIEW] HR Metrics AsyncState: $hrMetricsAsync ---');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(deviceName.isEmpty ? 'HR Monitor' : deviceName),
        actions: [
          connectionStatus.when(
            data: (status) => TextButton(
              onPressed: () {
                ref.read(bluetoothConnectionControllerProvider.notifier).disconnect();
                Navigator.of(context).pop();
              },
              child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Heart rate',
              style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Reaktivy odczyt telemetryczny
            hrMetricsAsync.when(
              data: (metric) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 48),
                      const SizedBox(width: 12),
                      Text(
                        '${metric.bpm}',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'BPM',
                        style: TextStyle(fontSize: 24, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (metric.rrIntervals.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'R-R: ${metric.rrIntervals.map((e) => '${(e * 1000).toStringAsFixed(0)}ms').join(', ')}',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                    ),
                  ],
                ],
              ),
              loading: () => const Center(
                child: Text('Waiting for data stream...', style: TextStyle(color: Colors.grey)),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: TextStyle(color: Colors.redAccent)),
              ),
            ),

            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.accessibility_new, color: Colors.blueAccent),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Body sensor location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('Chest', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
