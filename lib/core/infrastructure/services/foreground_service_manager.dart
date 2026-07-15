import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/heart_rate/domain/models/hr_measurement.dart';
import '../../../features/heart_rate/infrastructure/data/mappers/hr_measurement_mapper.dart';
import '../../../features/heart_rate/infrastructure/data/models/isar_hr_measurement.dart';
import '../../../features/heart_rate/infrastructure/parsers/hr_packet_parser.dart';

part 'foreground_service_manager.g.dart';

/// Root-level entry point for the foreground task isolate.
///
/// Must be a top-level function with [pragma] to prevent tree-shaking.
/// Registers [MyTaskHandler] so the isolate knows which handler to invoke.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

/// Task handler that defines the behavior inside the isolate running the
/// foreground service for the heart rate monitor workout session.
class MyTaskHandler extends TaskHandler {
  Isar? _isar;
  StreamSubscription<List<int>>? _hrSubscription;
  final Guid _hrServiceUuid = Guid('180d');
  final Guid _hrCharacteristicUuid = Guid('2a37');
  BluetoothDevice? _bleDevice;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('MyTaskHandler.onStart: Foreground service started at $timestamp');

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [HrWorkoutSessionSchema],
      directory: dir.path,
    );

    debugPrint('MyTaskHandler.onStart: Isar database opened in background isolate at ${dir.path}');

    await _setupBleSubscription();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    debugPrint('MyTaskHandler.onRepeatEvent: Periodic event at $timestamp');

    final isar = _isar;
    if (isar == null) {
      debugPrint('MyTaskHandler.onRepeatEvent: Isar not initialized, skipping write');
      return;
    }

    final session = HrWorkoutSession()
      ..startTime = timestamp
      ..endTime = timestamp
      ..samples = [
        IsarHrSample()
          ..bpm = 75
          ..rrIntervals = [0.8, 0.82, 0.79]
          ..timestamp = timestamp,
      ];

    isar.writeTxn(() async {
      await isar.collection<HrWorkoutSession>().put(session);
    }).then((_) {
      debugPrint('MyTaskHandler.onRepeatEvent: Wrote HrWorkoutSession to background Isar instance');
    }).catchError((error) {
      debugPrint('MyTaskHandler.onRepeatEvent: Failed to write HrWorkoutSession: $error');
    });
  }

  Future<void> _setupBleSubscription() async {
    final deviceId = await _getSelectedDeviceId();
    if (deviceId == null) {
      debugPrint('MyTaskHandler: No selected device ID, skipping BLE subscription');
      return;
    }

    _bleDevice = BluetoothDevice.fromId(deviceId);
    debugPrint('MyTaskHandler: Connecting to device ${_bleDevice!.remoteId}');

    try {
      await _bleDevice!.connect(autoConnect: false).timeout(const Duration(seconds: 5));
      debugPrint('MyTaskHandler: Device connected');

      final services = await _bleDevice!.discoverServices().timeout(const Duration(seconds: 5));
      debugPrint('MyTaskHandler: Services discovered: ${services.length}');

      final hrService = services
          .where((s) => s.serviceUuid == _hrServiceUuid)
          .firstOrNull;

      if (hrService == null) {
        debugPrint('MyTaskHandler: Heart Rate Service not found');
        return;
      }

      final hrCharacteristic = hrService.characteristics
          .where((c) => c.characteristicUuid == _hrCharacteristicUuid)
          .firstOrNull;

      if (hrCharacteristic == null) {
        debugPrint('MyTaskHandler: HR Measurement Characteristic not found');
        return;
      }

      await hrCharacteristic.setNotifyValue(true);
      debugPrint('MyTaskHandler: GATT notifications enabled');

      _hrSubscription = hrCharacteristic.onValueReceived.listen((rawBytes) {
        _handleHrMeasurement(rawBytes);
      }, onError: (error) {
        debugPrint('MyTaskHandler: HR characteristic error: $error');
      });
    } catch (e) {
      debugPrint('MyTaskHandler: BLE setup failed: $e');
    }
  }

  void _handleHrMeasurement(List<int> rawBytes) {
    final measurement = HrPacketParser.parseRawBytes(rawBytes);
    if (measurement == null) {
      debugPrint('MyTaskHandler: Failed to parse HR measurement');
      return;
    }

    debugPrint('MyTaskHandler: HR measurement received: ${measurement.bpm} bpm');

    _writeHrMeasurement(measurement);
  }

  void _writeHrMeasurement(HrMeasurement measurement) {
    final isar = _isar;
    if (isar == null) {
      debugPrint('MyTaskHandler: Isar not initialized, skipping HR write');
      return;
    }

    final sample = HrMeasurementMapper.toIsarSample(measurement);

    isar.writeTxn(() async {
      final session = HrWorkoutSession()
        ..startTime = measurement.timestamp
        ..endTime = measurement.timestamp
        ..samples = [sample];

      await isar.collection<HrWorkoutSession>().put(session);
    }).then((_) {
      debugPrint('MyTaskHandler: Wrote HR measurement to Isar: ${measurement.bpm} bpm');
    }).catchError((error) {
      debugPrint('MyTaskHandler: Failed to write HR measurement: $error');
    });
  }

  Future<String?> _getSelectedDeviceId() async {
    return await FlutterForegroundTask.getData<String>(key: 'selected_device_id');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('MyTaskHandler.onDestroy: Foreground service destroyed (timeout: $isTimeout) at $timestamp');

    await _hrSubscription?.cancel();
    _hrSubscription = null;

    if (_bleDevice != null) {
      try {
        await _bleDevice!.disconnect();
      } catch (e) {
        debugPrint('MyTaskHandler: Error disconnecting BLE device: $e');
      }
      _bleDevice = null;
    }

    await _isar?.close();
    _isar = null;

    debugPrint('MyTaskHandler.onDestroy: Isar database closed in background isolate');
  }
}

/// Service wrapper encapsulating the configuration and lifecycle of the Android
/// Foreground Service to keep the BLE connection alive in the background.
class ForegroundServiceManager {
  bool _isInitialized = false;

  /// Registers the currently selected BLE device ID for use by the background task.
  Future<void> setSelectedDeviceId(String deviceId) async {
    await FlutterForegroundTask.saveData(key: 'selected_device_id', value: deviceId);
  }

  /// Initializes the foreground task configuration. Must be called before starting.
  Future<void> init() async {
    if (_isInitialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'workout_channel',
        channelName: 'Workout Session',
        channelDescription: 'Keeps the heart rate monitor alive in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _isInitialized = true;
  }

  /// Configures the foreground task notification and ensures the service is
  /// non-dismissible. Must be called before [startService].
  Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'heart_rate_monitor_channel',
        channelName: 'Heart Rate Monitor',
        channelDescription: 'Recording workout...',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
        allowAutoRestart: true,
      ),
    );
  }

  /// Starts the foreground service and displays the permanent notification.
  Future<void> startService() async {
    await init();

    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'Heart Rate Monitor',
      notificationText: 'Recording workout...',
      notificationIcon: const NotificationIcon(
        metaDataName: 'ic_launcher',
      ),
      callback: startCallback,
    );
  }

  /// Stops the foreground service and removes the notification.
  Future<void> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

@riverpod
ForegroundServiceManager foregroundServiceManager(Ref ref) {
  return ForegroundServiceManager();
}
