import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Presentation-layer localization for [BodySensorLocation].
extension BodySensorLocationL10n on BodySensorLocation {
  /// Localized display name using [l10n].
  String localizedName(AppLocalizations l10n) => switch (this) {
    BodySensorLocation.other => l10n.bodySensorLocationOther,
    BodySensorLocation.chest => l10n.bodySensorLocationChest,
    BodySensorLocation.wrist => l10n.bodySensorLocationWrist,
    BodySensorLocation.finger => l10n.bodySensorLocationFinger,
    BodySensorLocation.hand => l10n.bodySensorLocationHand,
    BodySensorLocation.earLobe => l10n.bodySensorLocationEarLobe,
    BodySensorLocation.foot => l10n.bodySensorLocationFoot,
    BodySensorLocation.unknown => l10n.bodySensorLocationUnknown,
  };
}
