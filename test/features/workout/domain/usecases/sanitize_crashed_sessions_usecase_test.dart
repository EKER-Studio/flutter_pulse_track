// Use-case tests for SanitizeCrashedSessionsUseCase against a real Isar
// repository in a temporary directory.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:pulse_track/features/workout/domain/usecases/sanitize_crashed_sessions_usecase.dart';
import 'package:pulse_track/features/workout/infrastructure/models/device_profile_dto.dart';
import 'package:pulse_track/features/workout/infrastructure/models/workout_session_dto.dart';
import 'package:pulse_track/features/workout/infrastructure/repositories/workout_persistence_repository.dart';

Future<int> _putCrashedSession(
  Isar isar, {
  required List<int> samples,
  required DateTime startTime,
}) {
  final dto = WorkoutSessionDto()
    ..startTime = startTime
    ..endTime = null
    ..bpmSamples = samples
    ..avgBpm = samples.isEmpty ? 0 : 125
    ..maxBpm = samples.isEmpty ? 0 : 130
    ..sensorLocationIndex = 1
    ..deviceMacAddress = 'AA:BB:CC:DD:EE:01'
    ..deviceName = 'Sensor';
  return isar.writeTxn(() => isar.workoutSessionDtos.put(dto));
}

void main() {
  late Isar isar;
  late WorkoutPersistenceRepository repository;
  late SanitizeCrashedSessionsUseCase useCase;
  late Directory tmpDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('isar_sanitize_test_');
    isar = await Isar.open([
      DeviceProfileDtoSchema,
      WorkoutSessionDtoSchema,
    ], directory: tmpDir.path);
    repository = WorkoutPersistenceRepository(isar);
    useCase = SanitizeCrashedSessionsUseCase(repository);
  });

  tearDown(() async {
    await isar.close();
    tmpDir.deleteSync(recursive: true);
  });

  test('returns 0 when no crashed sessions exist', () async {
    expect(await useCase(), 0);
  });

  test('deletes empty crashed sessions', () async {
    await _putCrashedSession(
      isar,
      samples: [],
      startTime: DateTime(2025, 6, 1, 10).toUtc(),
    );

    expect(await useCase(), 1);
    expect(await isar.workoutSessionDtos.where().findAll(), isEmpty);
  });

  test('finalizes sessions by estimating endTime from sample count', () async {
    final startTime = DateTime(2025, 6, 1, 10).toUtc();
    final id = await _putCrashedSession(
      isar,
      samples: [120, 125, 130],
      startTime: startTime,
    );

    expect(await useCase(), 1);

    final updated = await isar.workoutSessionDtos.get(id);
    expect(updated, isNotNull);
    expect(
      updated!.endTime?.toUtc(),
      startTime.add(const Duration(seconds: 3)),
    );
    // Metrics and identity survive the in-place finalize.
    expect(updated.avgBpm, 125);
    expect(updated.deviceMacAddress, 'AA:BB:CC:DD:EE:01');
  });
}
