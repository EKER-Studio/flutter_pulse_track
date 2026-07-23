import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_zones.dart';

void main() {
  group('getZoneIndex with default maxHr (190)', () {
    test('Z1: 50-59% of maxHr', () {
      expect(getZoneIndex(95), 1);
      expect(getZoneIndex(100), 1);
      expect(getZoneIndex(113), 1);
    });

    test('Z2: 60-69% of maxHr', () {
      expect(getZoneIndex(114), 2);
      expect(getZoneIndex(130), 2);
      expect(getZoneIndex(131), 2);
    });

    test('Z3: 70-79% of maxHr', () {
      expect(getZoneIndex(133), 3);
      expect(getZoneIndex(150), 3);
      expect(getZoneIndex(150), 3);
    });

    test('Z4: 80-89% of maxHr', () {
      expect(getZoneIndex(152), 4);
      expect(getZoneIndex(170), 4);
    });

    test('Z5: 90-100% of maxHr', () {
      expect(getZoneIndex(171), 5);
      expect(getZoneIndex(180), 5);
      expect(getZoneIndex(190), 5);
    });

    test('below Z1 threshold (< 50%) returns 1', () {
      expect(getZoneIndex(40), 1);
      expect(getZoneIndex(10), 1);
      expect(getZoneIndex(0), 1);
    });

    test('at exact Z1 lower boundary (50%) returns 1', () {
      expect(getZoneIndex(95), 1);
    });

    test('at exact Z2 lower boundary (60%) returns 2', () {
      expect(getZoneIndex(114), 2);
    });

    test('at exact Z3 lower boundary (70%) returns 3', () {
      expect(getZoneIndex(133), 3);
    });

    test('at exact Z4 lower boundary (80%) returns 4', () {
      expect(getZoneIndex(152), 4);
    });

    test('at exact Z5 lower boundary (90%) returns 5', () {
      expect(getZoneIndex(171), 5);
    });

    test('above maxHr clamps to 100% and returns 5', () {
      expect(getZoneIndex(191), 5);
      expect(getZoneIndex(300), 5);
      expect(getZoneIndex(1000), 5);
    });

    test('negative BPM clamps to 0% and returns 1', () {
      expect(getZoneIndex(-10), 1);
      expect(getZoneIndex(-100), 1);
    });
  });

  group('getZoneIndex with custom maxHr', () {
    test('maxHr 200: zone boundaries shift proportionally', () {
      expect(getZoneIndex(100, maxHr: 200), 1);
      expect(getZoneIndex(120, maxHr: 200), 2);
      expect(getZoneIndex(140, maxHr: 200), 3);
      expect(getZoneIndex(160, maxHr: 200), 4);
      expect(getZoneIndex(180, maxHr: 200), 5);
    });

    test('maxHr 180: zone boundaries shift proportionally', () {
      expect(getZoneIndex(90, maxHr: 180), 1);
      expect(getZoneIndex(108, maxHr: 180), 2);
      expect(getZoneIndex(126, maxHr: 180), 3);
      expect(getZoneIndex(144, maxHr: 180), 4);
      expect(getZoneIndex(162, maxHr: 180), 5);
    });

    test('maxHr 1: any positive bpm clamps to 100%', () {
      expect(getZoneIndex(1, maxHr: 1), 5);
      expect(getZoneIndex(100, maxHr: 1), 5);
    });

    test('maxHr 1: zero bpm stays at 0%', () {
      expect(getZoneIndex(0, maxHr: 1), 1);
    });

    test('above maxHr with custom value still clamps', () {
      expect(getZoneIndex(250, maxHr: 200), 5);
    });
  });

  group('getZoneColor', () {
    test('returns correct color for each zone with default maxHr', () {
      expect(getZoneColor(95), kZoneColors[0]);
      expect(getZoneColor(114), kZoneColors[1]);
      expect(getZoneColor(133), kZoneColors[2]);
      expect(getZoneColor(152), kZoneColors[3]);
      expect(getZoneColor(171), kZoneColors[4]);
    });

    test('returns correct color with custom maxHr', () {
      expect(getZoneColor(100, maxHr: 200), kZoneColors[0]);
      expect(getZoneColor(120, maxHr: 200), kZoneColors[1]);
      expect(getZoneColor(140, maxHr: 200), kZoneColors[2]);
      expect(getZoneColor(160, maxHr: 200), kZoneColors[3]);
      expect(getZoneColor(180, maxHr: 200), kZoneColors[4]);
    });

    test('color for below-Z1 BPM matches Z1 color', () {
      expect(getZoneColor(0), kZoneColors[0]);
      expect(getZoneColor(-50), kZoneColors[0]);
    });

    test('color for above-maxHr BPM matches Z5 color', () {
      expect(getZoneColor(999), kZoneColors[4]);
    });

    test('color value is a valid non-null Color', () {
      expect(getZoneColor(150), isNotNull);
    });
  });

  group('kHeartRateZones constants', () {
    test('contains exactly 5 zones', () {
      expect(kHeartRateZones.length, 5);
    });

    test('zones are contiguous with no gaps', () {
      for (var i = 0; i < kHeartRateZones.length - 1; i++) {
        expect(
          kHeartRateZones[i + 1].minPercent,
          kHeartRateZones[i].maxPercent,
        );
      }
    });

    test('zone labels are Z1 through Z5', () {
      expect(kHeartRateZones[0].label, 'Z1');
      expect(kHeartRateZones[1].label, 'Z2');
      expect(kHeartRateZones[2].label, 'Z3');
      expect(kHeartRateZones[3].label, 'Z4');
      expect(kHeartRateZones[4].label, 'Z5');
    });

    test('first zone starts at 50%', () {
      expect(kHeartRateZones.first.minPercent, 0.50);
    });

    test('last zone ends at 100%', () {
      expect(kHeartRateZones.last.maxPercent, 1.00);
    });

    test('each zone color matches kZoneColors palette', () {
      for (var i = 0; i < kHeartRateZones.length; i++) {
        expect(kHeartRateZones[i].color, kZoneColors[i]);
      }
    });
  });

  group('kDefaultMaxHr constant', () {
    test('is 190', () {
      expect(kDefaultMaxHr, 190);
    });
  });
}
