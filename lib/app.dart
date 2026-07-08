import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/heart_rate/presentation/providers/bluetooth_connection_providers.dart';
import 'features/heart_rate/presentation/providers/bluetooth_scanner_providers.dart';
import 'features/heart_rate/presentation/views/hr_monitor_view.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanResultsAsync = ref.watch(bleScanResultsProvider);
    final isScanningAsync = ref.watch(bluetoothScannerControllerProvider);

    return MaterialApp(
      title: 'EKER Studio HR Companion',
      themeMode: ThemeMode.dark, // Force dark mode for athletic/medtech feel
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Scan HR Sensors'),
          actions: [
            isScanningAsync.when(
              data: (isScanning) => IconButton(
                icon: Icon(isScanning ? Icons.stop : Icons.search),
                onPressed: () {
                  final controller = ref.read(
                    bluetoothScannerControllerProvider.notifier,
                  );
                  if (isScanning) {
                    controller.stopScan();
                  } else {
                    controller.startHeartRateScan();
                  }
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, _) => const Icon(Icons.error),
            ),
          ],
        ),
        body: scanResultsAsync.when(
          data: (devices) {
            if (devices.isEmpty) {
              return const Center(
                child: Text(
                  'No heart rate monitors found.\nTap the search icon to scan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(
                    Icons.bluetooth,
                    color: Colors.blueAccent,
                  ),
                  title: Text(device.name),
                  subtitle: Text('ID: ${device.id}'),
                  trailing: Text('${device.rssi} dBm'),
                  onTap: () {
                    // 1. Stop scanning asynchronously to free up the BLE chip
                    ref.read(bluetoothScannerControllerProvider.notifier).stopScan();

                    // 2. Trigger connection without blocking the UI thread (no await here!)
                    ref.read(bluetoothConnectionControllerProvider.notifier).connect(device.id);

                    // 3. Navigate immediately so the user sees the connection lifecycle states
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HrMonitorView(
                          deviceId: device.id,
                          deviceName: device.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Scan Error: $err')),
        ),
      ),
    );
  }
}
