import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/heart_rate/presentation/providers/bluetooth_scanner_providers.dart';
import 'features/heart_rate/presentation/views/hr_home_view.dart';

/// Root widget that configures the MaterialApp with dark theme and
/// watches the Bluetooth scanner controller to keep it alive for the
/// entire application lifecycle.
///
/// The [bluetoothScannerControllerProvider] is watched at the root level to
/// prevent Riverpod from disposing the scanner while the app is running,
/// ensuring BLE scanning state persists across navigation and screen transitions.
class App extends ConsumerWidget {
  /// Creates the root [App] widget.
  const App({super.key});

  @override
  /// Builds the material app with dark theme and [HrHomeView] as the home screen.
  ///
  /// Theme configuration uses Material 3 with a dark color scheme derived from
  /// [Colors.redAccent]. The [bluetoothScannerControllerProvider] is watched
  /// before returning the widget tree to keep the scanner alive.
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
