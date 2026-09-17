import 'package:isar_community/isar.dart';

part 'workout_session_dto.g.dart';

/// Isar collection persisting a complete, self-contained snapshot of a single
/// heart rate workout session.
///
/// Sessions are written atomically at close time and treated as immutable once
/// saved, enabling deterministic offline replay and reliable historical
/// analytics without live sensor access.
///
/// ### Schema notes
/// - [bpmSamples] stores the chronologically ordered BPM trace captured during
///   the session. Prefer flat [List<int>] over embedded objects to minimise Isar
///   write overhead for high-frequency sensor data.
/// - [sensorLocationIndex] stores the raw [BodySensorLocation.index] integer
///   instead of the enum itself to avoid Isar enum serialisation limitations
///   and to insulate the schema from future enum reordering.
/// - [startTime] is indexed for efficient chronological list queries and
///   date-range scans on the history view.
@collection
class WorkoutSessionDto {
  WorkoutSessionDto();

  /// Auto-incremented primary key managed by Isar.
  /// Never set this field manually; always leave it as [Isar.autoIncrement].
  Id id = Isar.autoIncrement;

  /// UTC timestamp marking the beginning of the workout session.
  ///
  /// Indexed with [IndexType.value] to enable O(log n) chronological sorts
  /// and range queries (e.g., "all sessions in the last 7 days").
  @Index(type: IndexType.value)
  late DateTime startTime;

  /// UTC timestamp marking the end of the workout session.
  ///
  /// Null if the session was interrupted before a clean close (e.g., app crash,
  /// Bluetooth drop). The UI should treat a null value as an incomplete session.
  @Index(type: IndexType.value)
  DateTime? endTime;

  /// Session-level average heart rate in beats per minute, computed at close
  /// time from all values in [bpmSamples].
  ///
  /// Storing the pre-computed average avoids iterating [bpmSamples] on every
  /// history-list render, which could be expensive for long sessions.
  late int avgBpm;

  /// Peak heart rate in beats per minute observed at any point during the session.
  late int maxBpm;

  /// Chronologically ordered list of every raw BPM reading captured during the
  /// session. Enables waveform chart replay on the session detail screen.
  ///
  /// Written in append order by the persistence layer; not sorted on write to
  /// preserve the original temporal relationship between samples.
  List<int> bpmSamples = [];

  /// Raw index of the [BodySensorLocation] enum value for the sensor used during
  /// this session, stored as an integer to prevent schema migration costs if the
  /// enum is extended in a future app version.
  ///
  /// Map back to the domain enum via:
  /// ```dart
  /// final location = BodySensorLocation.values[dto.sensorLocationIndex];
  /// ```
  late int sensorLocationIndex;

  /// Bluetooth hardware address (MAC on Android, UUID on iOS) of the BLE sensor
  /// that generated this session's data. Used to cross-reference with
  /// [DeviceProfileDto] in the history view.
  late String deviceMacAddress;

  /// Human-readable display name of the sensor device as broadcast at connection
  /// time. Stored here so the history view can display it without a join, even
  /// if the [DeviceProfileDto] record is later updated or deleted.
  late String deviceName;
}
