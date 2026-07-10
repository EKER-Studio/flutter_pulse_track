import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/heart_rate/presentation/providers/bluetooth_scanner_providers.dart';
import 'features/heart_rate/presentation/views/hr_home_view.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bluetoothScannerControllerProvider);

    return MaterialApp(
      title: 'EKER Studio HR Companion',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HrHomeView(),
    );
  }
}
