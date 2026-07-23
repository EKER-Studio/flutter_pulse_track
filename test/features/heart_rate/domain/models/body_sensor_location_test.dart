import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';

void main() {
  group('BodySensorLocation', () {
    test('has exactly 8 values', () {
      expect(BodySensorLocation.values, hasLength(8));
    });

    group('displayName', () {
      test('other -> Other', () {
        expect(BodySensorLocation.other.displayName, 'Other');
      });

      test('chest -> Chest', () {
        expect(BodySensorLocation.chest.displayName, 'Chest');
      });

      test('wrist -> Wrist', () {
        expect(BodySensorLocation.wrist.displayName, 'Wrist');
      });

      test('finger -> Finger', () {
        expect(BodySensorLocation.finger.displayName, 'Finger');
      });

      test('hand -> Hand', () {
        expect(BodySensorLocation.hand.displayName, 'Hand');
      });

      test('earLobe -> Ear Lobe', () {
        expect(BodySensorLocation.earLobe.displayName, 'Ear Lobe');
      });

      test('foot -> Foot', () {
        expect(BodySensorLocation.foot.displayName, 'Foot');
      });

      test('unknown -> Unknown', () {
        expect(BodySensorLocation.unknown.displayName, 'Unknown');
      });

      test('every value has a non-empty displayName', () {
        for (final location in BodySensorLocation.values) {
          expect(location.displayName, isNotEmpty);
        }
      });

      test('every displayName is unique', () {
        final names = BodySensorLocation.values
            .map((e) => e.displayName)
            .toSet();
        expect(names.length, BodySensorLocation.values.length);
      });
    });
  });
}
