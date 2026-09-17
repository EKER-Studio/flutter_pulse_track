import 'package:isar_community/isar.dart';

part 'device_profile_dto.g.dart';

/// Isar collection storing a cached profile for each BLE heart rate sensor
/// that has previously been connected to the app.
///
/// ### Upsert semantics
/// The `@Index(unique: true, replace: true)` annotation on [macAddress] gives
/// this collection upsert-by-MAC semantics: if a device is reconnected, the
/// existing profile record is **replaced** in-place rather than a duplicate
/// being inserted. This guarantees one canonical record per physical device
/// regardless of how many times it has been connected.
///
/// ### iOS note
/// On iOS the Bluetooth hardware does not expose the physical MAC address;
/// instead, [FlutterBluePlus] provides a stable per-app UUID (`remoteId.str`).
/// [macAddress] stores whichever identifier the platform provides. The field
/// name "macAddress" is retained for cross-platform naming consistency.
@collection
class DeviceProfileDto {
  DeviceProfileDto();

  /// Auto-incremented primary key managed by Isar.
  /// Never set this field manually; always leave it as [Isar.autoIncrement].
  Id id = Isar.autoIncrement;

  /// Bluetooth hardware address uniquely identifying the physical sensor.
  ///
  /// The [unique] constraint enforces exactly one record per device identifier.
  /// The [replace] flag instructs Isar to overwrite the existing row on a
  /// collision, which is the correct upsert semantic for a profile refresh on
  /// reconnection (name change, firmware update, location change).
  @Index(unique: true, replace: true)
  late String macAddress;

  /// Human-readable display name last broadcast by the sensor.
  ///
  /// Updated on every successful connection so the profile always reflects the
  /// most recently observed device advertisement.
  late String name;

  /// UTC timestamp of the most recent successful GATT connection to this device.
  ///
  /// Used to sort the "Recently connected" list and to decide whether a cached
  /// profile is stale enough to warrant a fresh GATT characteristic read on
  /// the next connection.
  @Index()
  late DateTime lastConnectedAt;

  /// Cached raw index of the [BodySensorLocation] enum for the sensor body
  /// location read from GATT characteristic 0x2A38 during the last session.
  ///
  /// Storing this avoids re-reading the optional 0x2A38 GATT characteristic on
  /// every reconnect when the user's wearing configuration has not changed.
  ///
  /// Defaults to 0 ([BodySensorLocation.other]) if 0x2A38 was not present on
  /// the sensor or if the read failed during the last connection.
  ///
  /// Map back to the domain enum via:
  /// ```dart
  /// final location = BodySensorLocation.values[dto.lastSensorLocationIndex];
  /// ```
  late int lastSensorLocationIndex;
}
