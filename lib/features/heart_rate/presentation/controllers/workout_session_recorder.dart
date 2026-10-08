import 'dart:async';

import 'package:pulse_track/core/utils/app_logger.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_partial_workout_session_usecase.dart';
import 'package:pulse_track/features/workout/domain/usecases/save_workout_session_usecase.dart';

const Duration _kCheckpointInterval = Duration(seconds: 30);

/// Handles heart rate sample collection, periodic disk checkpoints, and final session persistence.
class WorkoutSessionRecorder {
  final SaveWorkoutSessionUseCase saveWorkoutSessionUseCase;
  final SavePartialWorkoutSessionUseCase savePartialWorkoutSessionUseCase;

  final List<int> _collectedBpmSamples = [];
  DateTime? _sessionStartTime;
  String? _sessionDeviceId;
  String? _sessionDeviceName;
  int? _sessionSensorLocationIndex;
  int _currentBpmSum = 0;
  int _currentMaxBpm = 0;
  int? _checkpointSessionId;
  bool _checkpointInProgress = false;
  bool _saveInProgress = false;
  Timer? _checkpointTimer;

  WorkoutSessionRecorder({
    required this.saveWorkoutSessionUseCase,
    required this.savePartialWorkoutSessionUseCase,
  });

  /// Whether samples have been recorded in the current session.
  bool get hasSamples => _collectedBpmSamples.isNotEmpty;

  /// Whether a final save operation is currently in progress.
  bool get isSaveInProgress => _saveInProgress;

  /// Starts a new recording session with peripheral identifiers.
  void startNewSession({required String deviceId, required String deviceName}) {
    _collectedBpmSamples.clear();
    _currentBpmSum = 0;
    _currentMaxBpm = 0;
    _sessionStartTime = DateTime.now();
    _sessionDeviceId = deviceId;
    _sessionDeviceName = deviceName;
    _sessionSensorLocationIndex = null;
    _checkpointSessionId = null;
  }

  /// Sets the detected body sensor location index.
  void setSensorLocationIndex(int index) {
    _sessionSensorLocationIndex = index;
  }

  /// Records a new BPM sample into the active session.
  void recordSample(int bpm) {
    _collectedBpmSamples.add(bpm);
    _currentBpmSum += bpm;
    if (bpm > _currentMaxBpm) {
      _currentMaxBpm = bpm;
    }
  }

  /// Starts periodic checkpointing at 30-second intervals.
  void startCheckpointTimer({required bool Function() isConnected}) {
    stopCheckpointTimer();
    _checkpointTimer = Timer.periodic(_kCheckpointInterval, (_) {
      unawaited(checkpoint(isConnected: isConnected()));
    });
  }

  /// Stops the periodic checkpoint timer.
  void stopCheckpointTimer() {
    _checkpointTimer?.cancel();
    _checkpointTimer = null;
  }

  /// Persists a partial checkpoint if a session is currently active and connected.
  Future<void> checkpoint({required bool isConnected}) async {
    if (_checkpointInProgress) {
      log.d(
        '[WorkoutSessionRecorder] checkpoint() skipped — '
        'a checkpoint write is already in progress.',
      );
      return;
    }
    if (!isConnected ||
        _collectedBpmSamples.isEmpty ||
        _sessionStartTime == null ||
        _sessionDeviceId == null ||
        _sessionDeviceName == null) {
      return;
    }

    _checkpointInProgress = true;
    try {
      final avgBpm = (_currentBpmSum / _collectedBpmSamples.length).round();
      final newId = await savePartialWorkoutSessionUseCase.call(
        startTime: _sessionStartTime!,
        samples: List<int>.of(_collectedBpmSamples),
        sensorLocationIndex:
            _sessionSensorLocationIndex ?? BodySensorLocation.other.index,
        macAddress: _sessionDeviceId!,
        name: _sessionDeviceName!,
        avgBpm: avgBpm,
        maxBpm: _currentMaxBpm,
        existingId: _checkpointSessionId,
      );
      if (newId != null) _checkpointSessionId = newId;
      log.d(
        '[WorkoutSessionRecorder] Checkpoint saved at ${DateTime.now()} '
        'with ${_collectedBpmSamples.length} samples (row id: '
        '$_checkpointSessionId).',
      );
    } on Object catch (e) {
      log.e('[WorkoutSessionRecorder] Checkpoint failed', error: e);
    } finally {
      _checkpointInProgress = false;
    }
  }

  /// Saves the complete session to disk and resets internal session state.
  Future<void> saveFinalSession() async {
    if (_saveInProgress) {
      log.d(
        '[WorkoutSessionRecorder] saveFinalSession() skipped — '
        'a save is already in progress.',
      );
      return;
    }
    _saveInProgress = true;
    try {
      if (_collectedBpmSamples.isNotEmpty &&
          _sessionStartTime != null &&
          _sessionDeviceId != null &&
          _sessionDeviceName != null) {
        final samples = List<int>.from(_collectedBpmSamples);
        final startTime = _sessionStartTime!;
        final endTime = DateTime.now();
        final avgBpm = (_currentBpmSum / samples.length).round();

        await saveWorkoutSessionUseCase.call(
          startTime: startTime,
          endTime: endTime,
          samples: samples,
          sensorLocationIndex:
              _sessionSensorLocationIndex ?? BodySensorLocation.other.index,
          macAddress: _sessionDeviceId!,
          name: _sessionDeviceName!,
          avgBpm: avgBpm,
          maxBpm: _currentMaxBpm,
          existingId: _checkpointSessionId,
        );
      }
    } on Object catch (e) {
      log.e(
        '[WorkoutSessionRecorder] Failed to persist workout session (data may be lost)',
        error: e,
      );
    } finally {
      reset();
      _saveInProgress = false;
    }
  }

  /// Resets all session metrics and checkpoint identifiers.
  void reset() {
    _collectedBpmSamples.clear();
    _currentBpmSum = 0;
    _currentMaxBpm = 0;
    _sessionStartTime = null;
    _sessionDeviceId = null;
    _sessionDeviceName = null;
    _sessionSensorLocationIndex = null;
    _checkpointSessionId = null;
  }
}
