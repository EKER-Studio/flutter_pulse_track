import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/presentation/utils/body_sensor_location_l10n.dart';
import 'package:pulse_track/l10n/app_localizations_en.dart';
import 'package:pulse_track/l10n/app_localizations_pl.dart';

void main() {
  group('BodySensorLocationL10n', () {
    late AppLocalizationsEn en;
    late AppLocalizationsPl pl;

    setUp(() {
      en = AppLocalizationsEn();
      pl = AppLocalizationsPl();
    });

    group('en', () {
      test('other -> Other', () {
        expect(BodySensorLocation.other.localizedName(en), 'Other');
      });

      test('chest -> Chest', () {
        expect(BodySensorLocation.chest.localizedName(en), 'Chest');
      });

      test('wrist -> Wrist', () {
        expect(BodySensorLocation.wrist.localizedName(en), 'Wrist');
      });

      test('finger -> Finger', () {
        expect(BodySensorLocation.finger.localizedName(en), 'Finger');
      });

      test('hand -> Hand', () {
        expect(BodySensorLocation.hand.localizedName(en), 'Hand');
      });

      test('earLobe -> Ear Lobe', () {
        expect(BodySensorLocation.earLobe.localizedName(en), 'Ear Lobe');
      });

      test('foot -> Foot', () {
        expect(BodySensorLocation.foot.localizedName(en), 'Foot');
      });

      test('unknown -> Unknown', () {
        expect(BodySensorLocation.unknown.localizedName(en), 'Unknown');
      });
    });

    group('pl', () {
      test('other -> Inne', () {
        expect(BodySensorLocation.other.localizedName(pl), 'Inne');
      });

      test('chest -> Klatka piersiowa', () {
        expect(BodySensorLocation.chest.localizedName(pl), 'Klatka piersiowa');
      });

      test('wrist -> Nadgarstek', () {
        expect(BodySensorLocation.wrist.localizedName(pl), 'Nadgarstek');
      });

      test('finger -> Palec', () {
        expect(BodySensorLocation.finger.localizedName(pl), 'Palec');
      });

      test('hand -> Dłoń', () {
        expect(BodySensorLocation.hand.localizedName(pl), 'Dłoń');
      });

      test('earLobe -> Płatek ucha', () {
        expect(BodySensorLocation.earLobe.localizedName(pl), 'Płatek ucha');
      });

      test('foot -> Stopa', () {
        expect(BodySensorLocation.foot.localizedName(pl), 'Stopa');
      });

      test('unknown -> Nieznane', () {
        expect(BodySensorLocation.unknown.localizedName(pl), 'Nieznane');
      });
    });

    test('covers all enum values', () {
      expect(BodySensorLocation.values, hasLength(8));
      for (final loc in BodySensorLocation.values) {
        expect(loc.localizedName(en), isNotEmpty);
        expect(loc.localizedName(pl), isNotEmpty);
      }
    });
  });
}
