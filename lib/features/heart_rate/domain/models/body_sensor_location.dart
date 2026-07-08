/// Represents the official Bluetooth SIG standard body locations for heart rate sensors.
enum BodySensorLocation {
  other,
  chest,
  wrist,
  finger,
  hand,
  earLobe,
  foot,
  unknown;

  /// Returns a user-friendly display name for the UI layer.
  String get displayName => switch (this) {
    BodySensorLocation.other => 'Other',
    BodySensorLocation.chest => 'Chest',
    BodySensorLocation.wrist => 'Wrist',
    BodySensorLocation.finger => 'Finger',
    BodySensorLocation.hand => 'Hand',
    BodySensorLocation.earLobe => 'Ear Lobe',
    BodySensorLocation.foot => 'Foot',
    BodySensorLocation.unknown => 'Unknown',
  };
}
