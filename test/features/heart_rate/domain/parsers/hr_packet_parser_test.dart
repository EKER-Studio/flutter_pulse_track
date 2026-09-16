import 'dart:typed_data';

import 'package:pulse_track/features/heart_rate/domain/parsers/hr_packet_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HrPacketParser.parseRawBytes', () {
    test('returns null for empty data', () {
      final result = HrPacketParser.parseRawBytes([]);
      expect(result, isNull);
    });

    test('returns null for null-like empty list', () {
      final result = HrPacketParser.parseRawBytes(<int>[]);
      expect(result, isNull);
    });

    group('8-bit BPM flags (flags = 0x00)', () {
      test('parses 8-bit BPM correctly', () {
        // flags = 0x00 (8-bit BPM, no energy expended, no R-R intervals)
        // bpm = 120
        final rawData = Uint8List.fromList([0x00, 120]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 120);
        expect(result.rrIntervals, isEmpty);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses BPM = 0', () {
        final rawData = Uint8List.fromList([0x00, 0]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 0);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses BPM = 255 (max 8-bit value)', () {
        final rawData = Uint8List.fromList([0x00, 255]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 255);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('handles GrowableList input', () {
        final List<int> rawData = [0x00, 75];
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 75);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('16-bit BPM flags (flags = 0x01)', () {
      test('parses 16-bit BPM correctly (little-endian)', () {
        // flags = 0x01 (16-bit BPM)
        // bpm = 180 => 0x00B4 => [0xB4, 0x00] in little-endian
        final rawData = Uint8List.fromList([0x01, 0xB4, 0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 180);
        expect(result.rrIntervals, isEmpty);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses 16-bit BPM = 0', () {
        final rawData = Uint8List.fromList([0x01, 0x00, 0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 0);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses 16-bit BPM = 65535 (max uint16)', () {
        final rawData = Uint8List.fromList([0x01, 0xFF, 0xFF]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 65535);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses 16-bit BPM with mid-range value', () {
        // bpm = 12345 => 0x3039 => [0x39, 0x30] in little-endian
        final rawData = Uint8List.fromList([0x01, 0x39, 0x30]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 12345);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('Energy Expended flag (flags = 0x08)', () {
      test('skips energy expended field correctly', () {
        // flags = 0x08 (has energy expended, 8-bit BPM)
        // bpm = 90
        // energy expended = 500 => 0x01F4 => [0xF4, 0x01] in little-endian
        final rawData = Uint8List.fromList([0x08, 90, 0xF4, 0x01]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 90);
        expect(result.rrIntervals, isEmpty);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('handles energy expended = 0', () {
        // flags = 0x08, bpm = 60, energy expended = 0
        final rawData = Uint8List.fromList([0x08, 60, 0x00, 0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 60);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('handles energy expended = 65535 (max uint16)', () {
        // flags = 0x08, bpm = 100, energy expended = 65535
        final rawData = Uint8List.fromList([0x08, 100, 0xFF, 0xFF]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 100);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('R-R Intervals flag (flags = 0x10)', () {
      test('parses single R-R interval', () {
        // flags = 0x10 (has R-R intervals)
        // bpm = 60
        // R-R interval raw = 1024 => 1024/1024 = 1.0 second
        final rawData = Uint8List.fromList([0x10, 60, 0x00, 0x04]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 60);
        expect(result.rrIntervals, hasLength(1));
        expect(result.rrIntervals[0], closeTo(1.0, 1e-6));
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses multiple R-R intervals', () {
        // flags = 0x10
        // bpm = 75
        // R-R intervals: raw = 512 (0.5s), raw = 1024 (1.0s), raw = 2048 (2.0s)
        final rawData = Uint8List.fromList([
          0x10,
          75,
          0x00, 0x02, // 512 => 0.5s
          0x00, 0x04, // 1024 => 1.0s
          0x00, 0x08, // 2048 => 2.0s
        ]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 75);
        expect(result.rrIntervals, hasLength(3));
        expect(result.rrIntervals[0], closeTo(0.5, 1e-6));
        expect(result.rrIntervals[1], closeTo(1.0, 1e-6));
        expect(result.rrIntervals[2], closeTo(2.0, 1e-6));
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses R-R interval = 0', () {
        final rawData = Uint8List.fromList([0x10, 80, 0x00, 0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 80);
        expect(result.rrIntervals, hasLength(1));
        expect(result.rrIntervals[0], 0.0);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses R-R interval with max uint16 value', () {
        // raw = 65535 => 65535/1024 ≈ 64.0009765625
        final rawData = Uint8List.fromList([0x10, 80, 0xFF, 0xFF]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 80);
        expect(result.rrIntervals, hasLength(1));
        expect(result.rrIntervals[0], closeTo(65535 / 1024.0, 1e-6));
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses partial R-R interval data (truncated)', () {
        // flags = 0x10
        // bpm = 60
        // Only 1 byte of R-R data (should be 2 bytes) => should be ignored
        final rawData = Uint8List.fromList([0x10, 60, 0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 60);
        expect(result.rrIntervals, isEmpty);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('Combined flags (0x19 = 0x01 | 0x08 | 0x10)', () {
      test('parses 16-bit BPM + energy expended + R-R intervals', () {
        // flags = 0x19 (16-bit BPM + energy expended + R-R intervals)
        // bpm = 150 => [0x96, 0x00] in little-endian
        // energy expended = 250 => [0xFA, 0x00] in little-endian
        // R-R interval: raw = 1024 => 1.0s
        final rawData = Uint8List.fromList([
          0x19,
          0x96, 0x00, // bpm = 150
          0xFA, 0x00, // energy expended = 250
          0x00, 0x04, // R-R = 1.0s
        ]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 150);
        expect(result.rrIntervals, hasLength(1));
        expect(result.rrIntervals[0], closeTo(1.0, 1e-6));
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('parses 8-bit BPM + energy expended + R-R intervals', () {
        // flags = 0x18 (8-bit BPM + energy expended + R-R intervals)
        // bpm = 85
        // energy expended = 1000 => [0xE8, 0x03] in little-endian
        // R-R intervals: raw = 512 (0.5s), raw = 2048 (2.0s)
        final rawData = Uint8List.fromList([
          0x18,
          85, // bpm = 85
          0xE8, 0x03, // energy expended = 1000
          0x00, 0x02, // R-R = 0.5s
          0x00, 0x08, // R-R = 2.0s
        ]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 85);
        expect(result.rrIntervals, hasLength(2));
        expect(result.rrIntervals[0], closeTo(0.5, 1e-6));
        expect(result.rrIntervals[1], closeTo(2.0, 1e-6));
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('Edge cases - insufficient data', () {
      test(
        'returns null when 16-bit BPM data is truncated (1 byte missing)',
        () {
          // flags = 0x01 (16-bit BPM), but only 1 byte for BPM instead of 2
          final rawData = Uint8List.fromList([0x01, 0xB4]);
          final result = HrPacketParser.parseRawBytes(rawData);

          expect(result, isNull);
        },
      );

      test('returns null when 8-bit BPM data is missing', () {
        // flags = 0x00, but no byte for BPM
        final rawData = Uint8List.fromList([0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNull);
      });

      test('returns null when energy expended field is truncated', () {
        // flags = 0x08, bpm = 80, but only 1 byte for energy expended
        final rawData = Uint8List.fromList([0x08, 80, 0xF4]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNull);
      });

      test('returns null for single byte input', () {
        final rawData = Uint8List.fromList([0x00]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNull);
      });
    });

    group('Timestamp validation', () {
      test('sets timestamp to current time', () {
        final before = DateTime.now();
        final rawData = Uint8List.fromList([0x00, 80]);
        final result = HrPacketParser.parseRawBytes(rawData);
        final after = DateTime.now();

        expect(result, isNotNull);
        expect(
          result!.timestamp.isAfter(before) ||
              result.timestamp.isAtSameMomentAs(before),
          true,
        );
        expect(
          result.timestamp.isBefore(after) ||
              result.timestamp.isAtSameMomentAs(after),
          true,
        );
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('Flags edge values', () {
      test('handles flags = 0x00 (no optional fields)', () {
        final rawData = Uint8List.fromList([0x00, 70]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 70);
        expect(result.rrIntervals, isEmpty);
        expect(result.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('handles flags = 0xFF (all flags set, 16-bit BPM)', () {
        // flags = 0xFF (16-bit BPM + energy expended + R-R intervals)
        // bpm = 100 => [0x64, 0x00] in little-endian
        // energy expended = 0 => [0x00, 0x00]
        // R-R = 1024 => 1.0s
        final rawData = Uint8List.fromList([
          0xFF,
          0x64, 0x00, // bpm = 100
          0x00, 0x00, // energy expended = 0
          0x00, 0x04, // R-R = 1.0s
        ]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 100);
        expect(result.rrIntervals, hasLength(1));
        expect(result.rrIntervals[0], closeTo(1.0, 1e-6));
        expect(result.sensorContactSupported, true);
        expect(result.sensorContactActive, true);
      });
    });

    group('Sensor Contact Status', () {
      test('Case A: flags = 0x00 (sensor contact not supported)', () {
        const flags = 0x00;
        final rawData = Uint8List.fromList([flags, 72]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });

      test('Case B: flags = 0x04 (sensor contact supported, not detected)', () {
        // bit2 = 1 (supported), bit1 = 0 (not detected)
        const flags = 0x04;
        final rawData = Uint8List.fromList([flags, 72]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.sensorContactSupported, true);
        expect(result.sensorContactActive, false);
      });

      test('Case C: flags = 0x06 (sensor contact supported and detected)', () {
        // bit2 = 1 (supported), bit1 = 1 (detected)
        const flags = 0x06;
        final rawData = Uint8List.fromList([flags, 72]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.sensorContactSupported, true);
        expect(result.sensorContactActive, true);
      });

      test('Case D: flags = 0x02 (bit1 active without bit2 support)', () {
        // bit2 = 0, bit1 = 1 → must NOT be treated as supported
        const flags = 0x02;
        final rawData = Uint8List.fromList([flags, 72]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.sensorContactSupported, false);
        expect(result.sensorContactActive, isNull);
      });
    });

    group('Complex flag combinations (all fields active)', () {
      test(
        'flags = 0x1F: 16-bit BPM + contact active + energy expended + R-R',
        () {
          // flags = 0x1F (0x01 16bit | 0x02 contact active | 0x04 contact supported | 0x08 energy | 0x10 RR)
          // bpm = 160 => [0xA0, 0x00]
          // energy expended = 300 => [0x2C, 0x01]
          // R-R = 819 (0.8s) => [0x33, 0x03], R-R = 1228 (1.2s) => [0xCC, 0x04]
          final rawData = Uint8List.fromList([
            0x1F,
            0xA0, 0x00, // bpm 160
            0x2C, 0x01, // energy 300
            0x33, 0x03, // R-R 819 (0.8s)
            0xCC, 0x04, // R-R 1228 (1.2s)
          ]);
          final result = HrPacketParser.parseRawBytes(rawData);

          expect(result, isNotNull);
          expect(result!.bpm, 160);
          expect(result.sensorContactSupported, true);
          expect(result.sensorContactActive, true);
          expect(result.rrIntervals, hasLength(2));
          expect(result.rrIntervals[0], closeTo(819 / 1024.0, 1e-3));
          expect(result.rrIntervals[1], closeTo(1228 / 1024.0, 1e-3));
        },
      );

      test(
        'flags = 0x1D: 16-bit BPM + contact inactive + energy expended + R-R',
        () {
          // flags = 0x1D (0x01 16bit | 0x04 contact supported | 0x08 energy | 0x10 RR)
          final rawData = Uint8List.fromList([
            0x1D,
            0xA0, 0x00, // bpm 160
            0x2C, 0x01, // energy 300
            0x00, 0x04, // R-R 1024 (1.0s)
          ]);
          final result = HrPacketParser.parseRawBytes(rawData);

          expect(result, isNotNull);
          expect(result!.bpm, 160);
          expect(result.sensorContactSupported, true);
          expect(result.sensorContactActive, false);
          expect(result.rrIntervals, hasLength(1));
          expect(result.rrIntervals[0], closeTo(1.0, 1e-6));
        },
      );

      test('flags = 0x14: 8-bit BPM + contact inactive + R-R (no energy)', () {
        // flags = 0x14 (0x04 contact supported | 0x10 RR)
        final rawData = Uint8List.fromList([
          0x14,
          70, // bpm 70
          0x00, 0x04, // R-R 1.0s
        ]);
        final result = HrPacketParser.parseRawBytes(rawData);

        expect(result, isNotNull);
        expect(result!.bpm, 70);
        expect(result.sensorContactSupported, true);
        expect(result.sensorContactActive, false);
        expect(result.rrIntervals, hasLength(1));
        expect(result.rrIntervals[0], closeTo(1.0, 1e-6));
      });
    });
  });
}
