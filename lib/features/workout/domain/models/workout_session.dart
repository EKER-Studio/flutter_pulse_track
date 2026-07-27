/// Immutable domain representation of a heart rate workout session,
/// decoupled from the Isar persistence schema ([WorkoutSessionDto]).
///
/// Presentation-layer code (views, widgets) should depend on this type —
/// never on `WorkoutSessionDto` directly — so the UI has zero knowledge of
/// Isar's collection/query API and is free to evolve independently of the
/// storage schema.
class WorkoutSession {
  /// Stable identifier assigned by the persistence layer.
  final int id;

  /// UTC timestamp marking the beginning of the workout session.
  final DateTime startTime;

  /// UTC timestamp marking the end of the workout session.
  ///
  /// Null if the session was interrupted before a clean close (e.g. app
  /// crash, Bluetooth drop). Callers should treat a null value as an
  /// incomplete session.
  final DateTime? endTime;

  /// Session-level average heart rate in beats per minute.
  final int avgBpm;

  /// Peak heart rate in beats per minute observed during the session.
  final int maxBpm;

  /// Chronologically ordered list of every raw BPM reading captured.
  final List<int> bpmSamples;

  /// Raw index of the `BodySensorLocation` enum value for the sensor used
  /// during this session.
  final int sensorLocationIndex;

  /// Bluetooth hardware address of the BLE sensor that generated this
  /// session's data.
  final String deviceMacAddress;

  /// Human-readable display name of the sensor device at connection time.
  final String deviceName;

  /// Creates an immutable [WorkoutSession] with [id], [startTime], [endTime],
  /// [avgBpm], [maxBpm], [bpmSamples], [sensorLocationIndex], [deviceMacAddress],
  /// and [deviceName].
  const WorkoutSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.avgBpm,
    required this.maxBpm,
    required this.bpmSamples,
    required this.sensorLocationIndex,
    required this.deviceMacAddress,
    required this.deviceName,
  });
}
