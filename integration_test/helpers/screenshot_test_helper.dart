import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_device.dart';
import 'package:pulse_track/features/heart_rate/domain/models/ble_scanner_state.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/ble_scanner_notifier.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/hr_monitor_notifier.dart';
import 'package:pulse_track/features/workout/domain/models/device_profile.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Supported locales for screenshot automation.
const List<String> supportedScreenshotLocales = <String>['en', 'pl'];

/// Resolves the output directory prefix from the `--dart-define=SCREENSHOT_DEVICE` argument.
String getScreenshotPrefix() {
  const device = String.fromEnvironment(
    'SCREENSHOT_DEVICE',
    defaultValue: 'android/phone',
  );
  return device.isNotEmpty ? '$device/' : '';
}

/// Resolves the targeted locales from the `--dart-define=SCREENSHOT_LOCALE` argument.
List<String> getEffectiveLocales() {
  const localeFilter = String.fromEnvironment('SCREENSHOT_LOCALE');
  if (localeFilter.isNotEmpty &&
      supportedScreenshotLocales.contains(localeFilter)) {
    return [localeFilter];
  }
  return supportedScreenshotLocales;
}

/// Generates a list of realistic saved BLE sensor profiles for dashboard demonstrations.
List<DeviceProfile> generateMockSavedProfiles() {
  final now = DateTime.now();
  return [
    DeviceProfile(
      id: 1,
      macAddress: 'C3:28:84:91:DE:F1',
      name: 'Polar H10',
      lastConnectedAt: now.subtract(const Duration(hours: 2)),
      lastSensorLocationIndex: BodySensorLocation.chest.index,
    ),
    DeviceProfile(
      id: 2,
      macAddress: 'F4:12:4A:8B:20:E2',
      name: 'Garmin HRM-Pro',
      lastConnectedAt: now.subtract(const Duration(days: 1)),
      lastSensorLocationIndex: BodySensorLocation.chest.index,
    ),
    DeviceProfile(
      id: 3,
      macAddress: 'E8:01:76:D3:55:1A',
      name: 'Wahoo TICKR X',
      lastConnectedAt: now.subtract(const Duration(days: 4)),
      lastSensorLocationIndex: BodySensorLocation.chest.index,
    ),
  ];
}

/// Generates a list of discovered BLE devices with realistic signal strengths for scanner demonstrations.
List<BleDevice> generateMockScannerDevices() {
  return const [
    BleDevice(id: 'C3:28:84:91:DE:F1', name: 'Polar H10 9D42', rssi: -54),
    BleDevice(id: 'F4:12:4A:8B:20:E2', name: 'Garmin HRM-Pro Plus', rssi: -62),
    BleDevice(id: 'E8:01:76:D3:55:1A', name: 'Wahoo TICKR X', rssi: -71),
    BleDevice(id: 'A1:22:98:44:B0:12', name: 'Smart PulseBand 2', rssi: -82),
  ];
}

/// Generates a realistic live telemetry measurement for the active monitor demonstration.
HrMeasurement generateMockLiveMeasurement() {
  return HrMeasurement(
    bpm: 142,
    timestamp: DateTime.now(),
    sensorContactSupported: true,
    sensorContactActive: true,
    rrIntervals: const [0.845, 0.852, 0.839],
    sensorLocation: BodySensorLocation.chest,
    batteryLevel: 88,
  );
}

/// Generates realistic BPM sample waveform data for workout analytics.
///
/// Produces a curve featuring a gradual warm-up, 3 high-intensity intervals
/// reaching anaerobic zones, recovery valleys, and a cool-down.
List<int> generateMockWorkoutWaveform() {
  final samples = <int>[];
  const totalPoints = 180;

  for (int i = 0; i < totalPoints; i++) {
    final progress = i / totalPoints;
    double bpm;

    if (progress < 0.15) {
      // Warm-up: 90 -> 130
      bpm = 90.0 + (progress / 0.15) * 40.0;
    } else if (progress < 0.85) {
      // Intervals: baseline ~145 with 3 surges up to 182
      final intervalProgress = (progress - 0.15) / 0.70;
      final wave = math.sin(
        intervalProgress * 3.0 * math.pi * 2.0 - math.pi / 2,
      );
      bpm = 152.0 + wave * 26.0;
    } else {
      // Cool-down: 145 -> 105
      final coolDownProgress = (progress - 0.85) / 0.15;
      bpm = 145.0 - coolDownProgress * 40.0;
    }

    // Micro-fluctuation for physiological realism
    final noise = ((i * 13) % 7 - 3) * 0.8;
    samples.add((bpm + noise).round().clamp(75, 195));
  }

  return samples;
}

/// Generates a list of completed workout sessions for history demonstrations.
List<WorkoutSession> generateMockWorkoutSessions() {
  final now = DateTime.now();
  final detailedSamples = generateMockWorkoutWaveform();

  final session1Start = DateTime(now.year, now.month, now.day, 7, 30);
  final session1End = session1Start.add(
    const Duration(minutes: 48, seconds: 20),
  );

  final session2Start = DateTime(now.year, now.month, now.day - 1, 18, 15);
  final session2End = session2Start.add(const Duration(hours: 1, minutes: 12));

  final session3Start = DateTime(now.year, now.month, now.day - 3, 8);
  final session3End = session3Start.add(
    const Duration(minutes: 36, seconds: 45),
  );

  return [
    WorkoutSession(
      id: 101,
      startTime: session1Start,
      endTime: session1End,
      avgBpm: 152,
      maxBpm: 182,
      bpmSamples: detailedSamples,
      sensorLocationIndex: BodySensorLocation.chest.index,
      deviceMacAddress: 'C3:28:84:91:DE:F1',
      deviceName: 'Polar H10',
    ),
    WorkoutSession(
      id: 102,
      startTime: session2Start,
      endTime: session2End,
      avgBpm: 141,
      maxBpm: 168,
      bpmSamples: const [120, 135, 142, 148, 155, 160, 165, 150, 140, 130],
      sensorLocationIndex: BodySensorLocation.chest.index,
      deviceMacAddress: 'F4:12:4A:8B:20:E2',
      deviceName: 'Garmin HRM-Pro',
    ),
    WorkoutSession(
      id: 103,
      startTime: session3Start,
      endTime: session3End,
      avgBpm: 128,
      maxBpm: 145,
      bpmSamples: const [110, 118, 125, 130, 138, 142, 135, 122, 115],
      sensorLocationIndex: BodySensorLocation.chest.index,
      deviceMacAddress: 'E8:01:76:D3:55:1A',
      deviceName: 'Wahoo TICKR X',
    ),
  ];
}

/// Riverpod test notifier that supplies static or configured [BleScannerState].
class MockBleScannerNotifier extends BleScannerNotifier {
  final BleScannerState _mockState;

  /// Creates a mock notifier initialized with [_mockState].
  MockBleScannerNotifier(this._mockState);

  @override
  BleScannerState build() => _mockState;

  @override
  Future<void> startScan() async {}

  @override
  Future<void> stopScan() async {}
}

/// Riverpod test notifier that supplies static or configured [MonitorState].
class MockHrMonitorNotifier extends HrMonitorNotifier {
  final MonitorState _mockState;

  /// Creates a mock monitor notifier initialized with [_mockState].
  MockHrMonitorNotifier(this._mockState);

  @override
  MonitorState build() => _mockState;

  @override
  Future<void> connect(String deviceId, String deviceName) async {}

  @override
  Future<void> disconnect() async {}
}

/// Device frame that emulates a realistic mobile status bar and bottom gesture navigation pill.
class ScreenshotDeviceFrame extends StatelessWidget {
  /// The underlying page content widget.
  final Widget child;

  /// Whether dark styling should be applied to system overlays.
  final bool isDark;

  /// Whether to render the PulseTrack notification icon in the status bar.
  final bool showNotificationIcon;

  /// Optional background color override for the status bar overlay.
  final Color? statusBarColor;

  /// Optional background color override for the navigation bar overlay.
  final Color? navigationBarColor;

  /// Creates a [ScreenshotDeviceFrame] with realistic system status and gesture bar.
  const ScreenshotDeviceFrame({
    super.key,
    required this.child,
    this.isDark = true,
    this.showNotificationIcon = true,
    this.statusBarColor,
    this.navigationBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: const EdgeInsets.only(top: 36.0, bottom: 20.0),
        viewPadding: const EdgeInsets.only(top: 36.0, bottom: 20.0),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // App Content
          child,

          // Mock System Status Bar (Overlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 36.0,
            child: IgnorePointer(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: statusBarColor ?? Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: Time + Notification icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '09:41',
                            style: TextStyle(
                              color: fgColor,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          if (showNotificationIcon) ...[
                            const SizedBox(width: 6.0),
                            Image.asset(
                              'assets/icon/app_icon_foreground.png',
                              width: 17.0,
                              height: 17.0,
                              color: fgColor.withValues(alpha: 0.9),
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ],
                        ],
                      ),
                      // Right side: Signal, Wi-Fi, Horizontal Battery
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.signal_cellular_alt,
                            color: fgColor,
                            size: 15.0,
                          ),
                          const SizedBox(width: 6.0),
                          Icon(Icons.wifi, color: fgColor, size: 15.0),
                          const SizedBox(width: 8.0),
                          // Horizontal battery indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: fgColor,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                padding: const EdgeInsets.all(1.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: fgColor,
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1.5,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: fgColor.withValues(alpha: 0.8),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(1.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Mock Bottom Gesture Navigation Bar (Overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 20.0,
            child: IgnorePointer(
              child: Container(
                color: navigationBarColor ?? Colors.transparent,
                alignment: Alignment.center,
                child: Container(
                  width: 134.0,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: fgColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds a self-contained [MaterialApp] wrapped in [ProviderScope] and [ScreenshotDeviceFrame].
Widget buildScreenshotAppWrapper({
  required Widget child,
  required Locale locale,
  List<Override> overrides = const [],
  bool isDark = true,
  bool showNotificationIcon = true,
}) {
  final themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentRed,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    useMaterial3: true,
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: themeData,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: ScreenshotDeviceFrame(
        isDark: isDark,
        showNotificationIcon: showNotificationIcon,
        child: child,
      ),
    ),
  );
}
