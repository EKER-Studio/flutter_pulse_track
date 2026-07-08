import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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

    final hrMetricsAsync = ref.watch(heartRateMetricsProvider(deviceId));
    final nativeDevice = BluetoothDevice.fromId(deviceId);

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
          // Stream Builder słuchający bezpośrednio hardware'u, ignorujący błędy stanów Riverpoda
          StreamBuilder<BluetoothConnectionState>(
            stream: nativeDevice.connectionState,
            initialData: BluetoothConnectionState.disconnected,
            builder: (context, snapshot) {
              final state = snapshot.data;

              if (state == BluetoothConnectionState.connected) {
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
                    // Wywołujemy rozłączenie przez nasz kontroler/serwis
                    await ref
                        .read(bluetoothConnectionControllerProvider.notifier)
                        .disconnect();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              }

              // Jeśli się łączy (connecting) lub rozłącza (disconnecting)
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            hrMetricsAsync.when(
              data: (metric) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 44,
                      ),
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
                ],
              ),
              loading: () => const Center(
                child: Column(
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
                  style: TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
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
                      Text(
                        'Body sensor location',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        'Chest',
                        style: TextStyle(
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
      ),
    );
  }
}
