import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulse_track/core/integrations/health/platform_detector.dart';
import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:url_launcher/url_launcher.dart';

/// Platform-neutral contract for interacting with Apple HealthKit or Google Health Connect.
abstract class HealthService {
  /// Checks whether HealthKit (iOS) or Health Connect (Android) is available on the device.
  Future<bool> isHealthApiAvailable();

  /// Checks if required read/write permissions for heart rate and workouts are granted.
  Future<bool> hasPermissions();

  /// Requests native operating system permissions for heart rate and workouts.
  Future<bool> requestPermissions();

  /// Opens the native system application settings screen.
  Future<bool> openSystemSettings();

  /// Opens the Google Play Store listing for Health Connect on Android.
  Future<void> installHealthConnect();

  /// Fetches historical heart rate measurements within a specified time range.
  ///
  /// @param start Beginning of the query window.
  /// @param end End of the query window.
  Future<List<HealthDataPoint>> fetchHeartRateHistory({
    required DateTime start,
    required DateTime end,
  });

  /// Fetches historical workout sessions within a specified time range.
  ///
  /// @param start Beginning of the query window.
  /// @param end End of the query window.
  Future<List<HealthDataPoint>> fetchWorkoutHistory({
    required DateTime start,
    required DateTime end,
  });

  /// Writes a single heart rate reading to the health store.
  ///
  /// @param bpm Beats per minute reading.
  /// @param timestamp Moment the reading was recorded.
  Future<bool> writeHeartRate({required int bpm, required DateTime timestamp});

  /// Writes a completed workout session to the health store.
  ///
  /// @param session Workout session entity to persist.
  Future<bool> writeWorkoutSession({required WorkoutSession session});
}

/// Production implementation of [HealthService] powered by `package:health`.
class NativeHealthService implements HealthService {
  /// Creates a [NativeHealthService] with optional dependencies for testing.
  ///
  /// @param health Health plugin facade instance.
  /// @param platformDetector Operating system detector.
  NativeHealthService({Health? health, PlatformDetector? platformDetector})
    : _health = health ?? Health(),
      _platformDetector = platformDetector ?? const NativePlatformDetector();

  /// Shared singleton instance of [NativeHealthService].
  static final NativeHealthService instance = NativeHealthService();

  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataType> _healthDataTypesReadWrite = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataAccess> _healthDataAccessReadWrite = [
    HealthDataAccess.READ,
    HealthDataAccess.WRITE,
    HealthDataAccess.READ,
    HealthDataAccess.WRITE,
  ];

  static const Duration _operationTimeout = Duration(seconds: 5);

  static const String _healthConnectPackageId =
      'com.google.android.apps.healthdata';

  static final Uri _healthConnectMarketUri = Uri.parse(
    'market://details?id=$_healthConnectPackageId',
  );

  static final Uri _healthConnectPlayStoreUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=$_healthConnectPackageId',
  );

  final Health _health;
  final PlatformDetector _platformDetector;
  bool _isConfigured = false;

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      try {
        await _health.configure();
        _isConfigured = true;
      } on Object catch (e, stack) {
        log.e(
          '[HealthService] Health plugin configuration failed',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }

  @override
  Future<bool> isHealthApiAvailable() async {
    try {
      if (!_platformDetector.isAndroid) {
        return true;
      }
      await _ensureConfigured();
      final sdkStatus = await _health.getHealthConnectSdkStatus();
      return sdkStatus == HealthConnectSdkStatus.sdkAvailable;
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] isHealthApiAvailable failed',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      await _ensureConfigured();
      if (_platformDetector.isIOS) {
        final writeGranted = await _health
            .hasPermissions(
              _healthDataTypes,
              permissions: const [
                HealthDataAccess.WRITE,
                HealthDataAccess.WRITE,
              ],
            )
            .timeout(_operationTimeout);
        return writeGranted ?? false;
      }
      final granted = await _health
          .hasPermissions(
            _healthDataTypesReadWrite,
            permissions: _healthDataAccessReadWrite,
          )
          .timeout(_operationTimeout);
      return granted ?? false;
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] hasPermissions failed',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      await _ensureConfigured();
      final bool granted;
      try {
        granted = await _health
            .requestAuthorization(
              _healthDataTypesReadWrite,
              permissions: _healthDataAccessReadWrite,
            )
            .timeout(_operationTimeout);
      } on Object catch (e, stack) {
        log.e(
          '[HealthService] requestAuthorization failed',
          error: e,
          stackTrace: stack,
        );
        return false;
      }

      if (!granted) {
        return false;
      }

      if (_platformDetector.isIOS) {
        return await hasPermissions();
      }
      return granted;
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] requestPermissions failed',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  @override
  Future<bool> openSystemSettings() async {
    try {
      return await openAppSettings().timeout(_operationTimeout);
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] openSystemSettings failed',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  @override
  Future<void> installHealthConnect() async {
    if (!_platformDetector.isAndroid) {
      return;
    }
    try {
      final marketLaunched = await launchUrl(_healthConnectMarketUri);
      if (!marketLaunched) {
        await launchUrl(
          _healthConnectPlayStoreUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] installHealthConnect failed',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  Future<List<HealthDataPoint>> fetchHeartRateHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await _ensureConfigured();
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
        preferredUnits: const {
          HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
        },
      );
      return points;
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] fetchHeartRateHistory error',
        error: e,
        stackTrace: stack,
      );
      return const [];
    }
  }

  @override
  Future<List<HealthDataPoint>> fetchWorkoutHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await _ensureConfigured();
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );
      return points;
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] fetchWorkoutHistory error',
        error: e,
        stackTrace: stack,
      );
      return const [];
    }
  }

  @override
  Future<bool> writeHeartRate({
    required int bpm,
    required DateTime timestamp,
  }) async {
    try {
      await _ensureConfigured();
      return await _health.writeHealthData(
        value: bpm.toDouble(),
        unit: HealthDataUnit.BEATS_PER_MINUTE,
        type: HealthDataType.HEART_RATE,
        startTime: timestamp,
        endTime: timestamp,
        recordingMethod: RecordingMethod.manual,
      );
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] writeHeartRate error',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  @override
  Future<bool> writeWorkoutSession({required WorkoutSession session}) async {
    try {
      await _ensureConfigured();
      final start = session.startTime;
      final end =
          session.endTime ??
          (session.bpmSamples.isNotEmpty
              ? session.startTime.add(
                  Duration(seconds: session.bpmSamples.length),
                )
              : session.startTime.add(const Duration(minutes: 1)));
      final title = session.deviceName.isNotEmpty
          ? session.deviceName
          : 'PulseTrack Workout';

      final workoutSuccess = await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.OTHER,
        start: start,
        end: end,
        title: title,
        recordingMethod: RecordingMethod.manual,
      );

      if (workoutSuccess && session.avgBpm > 0) {
        try {
          await _health.writeHealthData(
            value: session.avgBpm.toDouble(),
            unit: HealthDataUnit.BEATS_PER_MINUTE,
            type: HealthDataType.HEART_RATE,
            startTime: start,
            endTime: end,
            recordingMethod: RecordingMethod.manual,
          );
        } on Object catch (e, stack) {
          log.w(
            '[HealthService] Failed to write average heart rate data point for workout session',
            error: e,
            stackTrace: stack,
          );
        }
      }

      return workoutSuccess;
    } on Object catch (e, stack) {
      log.e(
        '[HealthService] writeWorkoutSession error',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}
