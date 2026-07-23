import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

HrMeasurement _measurement({
  int bpm = 72,
  List<double> rrIntervals = const [],
  DateTime? timestamp,
  BodySensorLocation sensorLocation = BodySensorLocation.unknown,
  int? batteryLevel,
  bool sensorContactSupported = false,
  bool? sensorContactActive,
}) {
  return HrMeasurement(
    bpm: bpm,
    rrIntervals: rrIntervals,
    timestamp: timestamp ?? DateTime(2026, 7, 23, 14, 30, 0, 123),
    sensorLocation: sensorLocation,
    batteryLevel: batteryLevel,
    sensorContactSupported: sensorContactSupported,
    sensorContactActive: sensorContactActive,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('HrMeasurement constructor', () {
    test('sets all required fields', () {
      final ts = DateTime(2026, 7, 23, 14, 30, 0);
      final m = HrMeasurement(
        bpm: 120,
        rrIntervals: [0.5, 1.0],
        timestamp: ts,
      );
      expect(m.bpm, 120);
      expect(m.rrIntervals, [0.5, 1.0]);
      expect(m.timestamp, ts);
    });

    test('applies default values', () {
      final m = _measurement();
      expect(m.sensorLocation, BodySensorLocation.unknown);
      expect(m.batteryLevel, isNull);
      expect(m.sensorContactSupported, false);
      expect(m.sensorContactActive, isNull);
    });

    test('accepts optional batteryLevel', () {
      final m = _measurement(batteryLevel: 85);
      expect(m.batteryLevel, 85);
    });

    test('accepts optional sensor contact flags', () {
      final m = _measurement(
        sensorContactSupported: true,
        sensorContactActive: true,
      );
      expect(m.sensorContactSupported, true);
      expect(m.sensorContactActive, true);
    });

    test('accepts sensorContactActive null when unsupported', () {
      final m = _measurement(
        sensorContactSupported: false,
        sensorContactActive: null,
      );
      expect(m.sensorContactActive, isNull);
    });
  });

  group('copyWith', () {
    test('returns same instance when no args', () {
      final m = _measurement();
      final copy = m.copyWith();
      expect(copy.bpm, m.bpm);
      expect(copy.rrIntervals, m.rrIntervals);
      expect(copy.timestamp, m.timestamp);
      expect(copy.sensorLocation, m.sensorLocation);
      expect(copy.batteryLevel, m.batteryLevel);
      expect(copy.sensorContactSupported, m.sensorContactSupported);
      expect(copy.sensorContactActive, m.sensorContactActive);
    });

    test('overrides single field', () {
      final m = _measurement(bpm: 60);
      expect(m.copyWith(bpm: 80).bpm, 80);
    });

    test('overrides rrIntervals', () {
      final m = _measurement(rrIntervals: [0.5]);
      expect(m.copyWith(rrIntervals: [1.0, 2.0]).rrIntervals, [1.0, 2.0]);
    });

    test('overrides multiple fields', () {
      final m = _measurement();
      final now = DateTime(2027, 1, 1);
      final copy = m.copyWith(
        bpm: 200,
        timestamp: now,
        sensorLocation: BodySensorLocation.chest,
        batteryLevel: 50,
      );
      expect(copy.bpm, 200);
      expect(copy.timestamp, now);
      expect(copy.sensorLocation, BodySensorLocation.chest);
      expect(copy.batteryLevel, 50);
    });

    test('nullable field defaults preserve existing value (copyWith limitation)',
        () {
      final m = _measurement(batteryLevel: 80, sensorContactActive: true);
      final copy = m.copyWith(
        batteryLevel: null,
        sensorContactActive: null,
      );
      // copyWith uses ?? so null means "keep original" — construct a new
      // instance directly when a nullable field needs to be cleared.
      expect(copy.batteryLevel, 80);
      expect(copy.sensorContactActive, isTrue);
    });
  });

  group('operator ==', () {
    test('identical instances are equal', () {
      final m = _measurement();
      expect(m == m, isTrue);
    });

    test('same field values are equal', () {
      final ts = DateTime(2026, 1, 1);
      final a = _measurement(
        bpm: 100,
        rrIntervals: [0.5, 1.0],
        timestamp: ts,
        sensorLocation: BodySensorLocation.wrist,
        batteryLevel: 75,
        sensorContactSupported: true,
        sensorContactActive: true,
      );
      final b = _measurement(
        bpm: 100,
        rrIntervals: [0.5, 1.0],
        timestamp: ts,
        sensorLocation: BodySensorLocation.wrist,
        batteryLevel: 75,
        sensorContactSupported: true,
        sensorContactActive: true,
      );
      expect(a == b, isTrue);
    });

    test('different bpm is not equal', () {
      final a = _measurement(bpm: 60);
      final b = _measurement(bpm: 80);
      expect(a == b, isFalse);
    });

    test('different rrIntervals is not equal', () {
      final a = _measurement(rrIntervals: [0.5]);
      final b = _measurement(rrIntervals: [1.0]);
      expect(a == b, isFalse);
    });

    test('different rrInterval count is not equal', () {
      final a = _measurement(rrIntervals: [0.5, 1.0]);
      final b = _measurement(rrIntervals: [0.5]);
      expect(a == b, isFalse);
    });

    test('different timestamp is not equal', () {
      final a = _measurement(timestamp: DateTime(2026, 1, 1));
      final b = _measurement(timestamp: DateTime(2026, 6, 15));
      expect(a == b, isFalse);
    });

    test('different sensorLocation is not equal', () {
      final a = _measurement(sensorLocation: BodySensorLocation.chest);
      final b = _measurement(sensorLocation: BodySensorLocation.wrist);
      expect(a == b, isFalse);
    });

    test('different batteryLevel is not equal', () {
      final a = _measurement(batteryLevel: 50);
      final b = _measurement(batteryLevel: 100);
      expect(a == b, isFalse);
    });

    test('null vs non-null batteryLevel is not equal', () {
      final a = _measurement(batteryLevel: null);
      final b = _measurement(batteryLevel: 80);
      expect(a == b, isFalse);
    });

    test('different sensorContactSupported is not equal', () {
      final a = _measurement(sensorContactSupported: false);
      final b = _measurement(sensorContactSupported: true);
      expect(a == b, isFalse);
    });

    test('null vs non-null sensorContactActive is not equal', () {
      final a = _measurement(sensorContactActive: null);
      final b = _measurement(sensorContactActive: true);
      expect(a == b, isFalse);
    });

    test('returns false for non-HrMeasurement type', () {
      final m = _measurement();
      expect(m, isNot(equals(Object())));
    });
  });

  group('hashCode', () {
    test('same field values have same hashCode', () {
      final ts = DateTime(2026, 1, 1);
      final a = _measurement(
        bpm: 100,
        rrIntervals: [0.5],
        timestamp: ts,
        sensorLocation: BodySensorLocation.chest,
        batteryLevel: 50,
        sensorContactSupported: true,
        sensorContactActive: true,
      );
      final b = _measurement(
        bpm: 100,
        rrIntervals: [0.5],
        timestamp: ts,
        sensorLocation: BodySensorLocation.chest,
        batteryLevel: 50,
        sensorContactSupported: true,
        sensorContactActive: true,
      );
      expect(a.hashCode, b.hashCode);
    });

    test('different bpm has different hashCode', () {
      final a = _measurement(bpm: 60);
      final b = _measurement(bpm: 80);
      expect(a.hashCode == b.hashCode, isFalse);
    });

    test('different rrIntervals has different hashCode', () {
      final a = _measurement(rrIntervals: [0.5]);
      final b = _measurement(rrIntervals: [1.0]);
      expect(a.hashCode == b.hashCode, isFalse);
    });
  });

  group('rrIntervals list equality', () {
    test('empty lists are equal', () {
      final a = _measurement(rrIntervals: []);
      final b = _measurement(rrIntervals: []);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('equal double values match', () {
      final a = _measurement(rrIntervals: [0.5, 1.0, 1.5]);
      final b = _measurement(rrIntervals: [0.5, 1.0, 1.5]);
      expect(a == b, isTrue);
    });
  });
}