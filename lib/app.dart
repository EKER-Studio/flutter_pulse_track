import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/heart_rate/presentation/views/hr_home_view.dart';
import 'l10n/app_localizations.dart';

/// Root widget that configures the MaterialApp with a dark theme.
///
/// Actual BLE scanning is owned by [BleScannerNotifier] (`bleScannerProvider`),
/// which is watched directly by the scanner screen — it does not need to be
/// kept alive at the root of the app.
class App extends ConsumerWidget {
  /// Creates the root [App] widget.
  const App({super.key});

  @override
  /// Builds the material app with dark theme and [HrHomeView] as the home screen.
  ///
  /// Theme configuration uses Material 3 with a dark color scheme derived from
  /// [Colors.redAccent].
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PulseTrack',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HrHomeView(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
