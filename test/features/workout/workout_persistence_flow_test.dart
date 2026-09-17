// End-to-end persistence flow: save, retrieve, and export a workout
// session against a real Isar instance with no mocks.
//
// Covers the persist-to-export slice of the critical user journey
// (C-14). BLE scan and connect cannot run without radio hardware, so
// those stay behind fakes in the notifier tests.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pulse_track/features/workout/domain/services/workout_export_service.dart';
import 'package:pulse_track/features/workout/infrastructure/models/device_profile_dto.dart';
import 'package:pulse_track/features/workout/infrastructure/models/workout_session_dto.dart';
import 'package:pulse_track/features/workout/infrastructure/repositories/workout_persistence_repository.dart';

void main() {
  late Isar isar;
  late WorkoutPersistenceRepository repository;
  late Directory tmpDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('isar_flow_test_');
    isar = await Isar.open([
      DeviceProfileDtoSchema,
      WorkoutSessionDtoSchema,
    ], directory: tmpDir.path);
    repository = WorkoutPersistenceRepository(isar);
  });

  tearDown(() async {
    await isar.close();
    tmpDir.deleteSync(recursive: true);
  });

  test('checkpoint, finalize, stream, and export round-trip', () async {
    final startTime = DateTime(2026, 9, 1, 10).toUtc();
    const samples = [120, 125, 130];

    // In-progress checkpoint returns a row id for later finalization.
    final rowId = await repository.saveWorkoutCheckpoint(
      startTime: startTime,
      samples: samples,
      sensorLocationIndex: 1,
      macAddress: 'AA:BB:CC:DD:EE:01',
      name: 'Polar H10',
      avgBpm: 125,
      maxBpm: 130,
    );
    expect(rowId, isNotNull);

    // Final write updates the same row instead of duplicating it.
    final endTime = startTime.add(const Duration(seconds: 3));
    await repository.saveWorkoutSession(
      startTime: startTime,
      endTime: endTime,
      samples: samples,
      sensorLocationIndex: 1,
      macAddress: 'AA:BB:CC:DD:EE:01',
      name: 'Polar H10',
      avgBpm: 125,
      maxBpm: 130,
      existingId: rowId,
    );

    final rows = await isar.workoutSessionDtos.where().findAll();
    expect(rows, hasLength(1));

    // History stream surfaces the finalized session.
    final history = await repository.watchWorkoutHistory().first;
    expect(history, hasLength(1));
    expect(history.first.avgBpm, 125);
    expect(history.first.endTime?.toUtc(), endTime);

    // Export renders the persisted session to CSV.
    final csv = await WorkoutExportService().generateCsv(history.first);
    expect(csv, contains('Timestamp'));
    expect(csv, contains('125'));
  });

  test('device profile round-trip feeds direct connect', () async {
    await repository.saveDeviceProfile(
      macAddress: 'AA:BB:CC:DD:EE:01',
      name: 'Polar H10',
      sensorLocationIndex: 1,
    );

    final profiles = await repository.watchSavedDeviceProfiles().first;
    expect(profiles, hasLength(1));
    expect(profiles.first.macAddress, 'AA:BB:CC:DD:EE:01');
    expect(profiles.first.name, 'Polar H10');
  });
}
