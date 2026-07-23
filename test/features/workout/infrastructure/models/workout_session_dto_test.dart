import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pulse_track/features/workout/infrastructure/models/workout_session_dto.dart';

void main() {
  group('WorkoutSessionDto', () {
    test('default id is Isar.autoIncrement', () {
      final dto = WorkoutSessionDto();
      expect(dto.id, Isar.autoIncrement);
    });

    test('default bpmSamples is empty list', () {
      final dto = WorkoutSessionDto();
      expect(dto.bpmSamples, isEmpty);
    });

    test('default endTime is null', () {
      final dto = WorkoutSessionDto();
      expect(dto.endTime, isNull);
    });

    test('assigns all fields', () {
      final now = DateTime(2026, 7, 23);
      final dto = WorkoutSessionDto()
        ..id = 42
        ..startTime = now
        ..endTime = now.add(const Duration(hours: 1))
        ..avgBpm = 78
        ..maxBpm = 142
        ..bpmSamples = [60, 72, 88]
        ..sensorLocationIndex = 2
        ..deviceMacAddress = 'AA:BB:CC:DD:EE:FF'
        ..deviceName = 'Polar H10';

      expect(dto.id, 42);
      expect(dto.startTime, now);
      expect(dto.endTime, now.add(const Duration(hours: 1)));
      expect(dto.avgBpm, 78);
      expect(dto.maxBpm, 142);
      expect(dto.bpmSamples, [60, 72, 88]);
      expect(dto.sensorLocationIndex, 2);
      expect(dto.deviceMacAddress, 'AA:BB:CC:DD:EE:FF');
      expect(dto.deviceName, 'Polar H10');
    });

    test('accepts null endTime after assignment', () {
      final dto = WorkoutSessionDto()..endTime = null;

      expect(dto.endTime, isNull);
    });

    test('accepts empty bpmSamples after assignment', () {
      final dto = WorkoutSessionDto()..bpmSamples = [];

      expect(dto.bpmSamples, isEmpty);
    });

    test('id can be changed from default', () {
      final dto = WorkoutSessionDto()..id = 99;

      expect(dto.id, 99);
      expect(dto.id, isNot(equals(Isar.autoIncrement)));
    });

    test('retains assigned id after field changes', () {
      final dto = WorkoutSessionDto()
        ..id = 5
        ..avgBpm = 80;

      expect(dto.id, 5);
      expect(dto.avgBpm, 80);
    });
  });
}
