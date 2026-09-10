/// Represents the official Bluetooth SIG standard body locations for heart rate sensors.
///
/// Decoded from GATT Characteristic 0x2A38 (Body Sensor Location).
enum BodySensorLocation {
  /// Generic or unspecified sensor placement.
  other,

  /// Sensor worn around the chest (e.g., HRM strap).
  chest,

  /// Sensor worn on the wrist (e.g., smartwatch).
  wrist,

  /// Sensor worn on a finger (e.g., ring).
  finger,

  /// Sensor worn on the hand (e.g., handheld grip).
  hand,

  /// Sensor worn in the ear (e.g., earbud).
  earLobe,

  /// Sensor worn on the foot (e.g., shoe insole).
  foot,

  /// Sensor location could not be determined from the device.
  unknown;

  /// Returns a user-friendly display name for the UI layer.
  ///
  /// For localized UI, use `BodySensorLocationX.localizedName(l10n)` in
  /// `lib/features/heart_rate/presentation/utils/body_sensor_location_l10n.dart`.
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
