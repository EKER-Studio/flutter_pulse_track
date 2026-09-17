import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/infrastructure/storage/database_module.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

const MethodChannel _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

String _b64(Uint8List bytes) => base64Encode(bytes);

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory workDir;
  late Directory docsDir;
  final Map<String, String?> secureStore = {};
  Object? secureReadError;

  setUp(() {
    workDir = Directory.systemTemp.createTempSync('db_module_test_');
    docsDir = Directory.systemTemp.createTempSync('db_module_docs_');
    secureStore.clear();
    secureReadError = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return docsDir.path;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (call) async {
          final args = call.arguments;
          final key = args is Map ? args['key'] as String? : null;
          switch (call.method) {
            case 'read':
              if (secureReadError != null) throw secureReadError!;
              return secureStore[key];
            case 'write':
              if (key != null && args is Map) {
                secureStore[key] = args['value'] as String?;
              }
              return null;
            case 'delete':
              if (key != null) secureStore.remove(key);
              return null;
            case 'readAll':
              return Map<String, String>.from(
                secureStore.map((k, v) => MapEntry(k, v ?? '')),
              );
            case 'deleteAll':
              secureStore.clear();
              return null;
            case 'containsKey':
              return key != null && secureStore.containsKey(key);
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
    if (workDir.existsSync()) workDir.deleteSync(recursive: true);
    if (docsDir.existsSync()) docsDir.deleteSync(recursive: true);
  });

  group('quarantineLegacyDatabaseForTesting', () {
    test('renames legacy db file to .legacy.bak', () async {
      final legacy = File('${workDir.path}/pulse_track_v0.isar')
        ..writeAsStringSync('legacy-payload');

      await DatabaseModule.quarantineLegacyDatabaseForTesting(workDir.path);

      expect(legacy.existsSync(), isFalse);
      final quarantined = File('${workDir.path}/pulse_track_v0.legacy.bak');
      expect(quarantined.existsSync(), isTrue);
      expect(quarantined.readAsStringSync(), 'legacy-payload');
    });

    test('does nothing when no legacy db file exists', () async {
      await DatabaseModule.quarantineLegacyDatabaseForTesting(workDir.path);

      expect(workDir.listSync(), isEmpty);
    });
  });

  group('createPreImportSnapshot', () {
    test('copies db file to snapshot and returns its path', () async {
      File('${workDir.path}/pulse_track_v1.isar')
          .writeAsStringSync('db-payload');

      final snapshotPath = await DatabaseModule.createPreImportSnapshot(
        workDir.path,
      );

      expect(
        snapshotPath,
        '${workDir.path}/pulse_track_v1_pre_import.isar.bak',
      );
      expect(File(snapshotPath!).readAsStringSync(), 'db-payload');
      // Original stays in place.
      expect(File('${workDir.path}/pulse_track_v1.isar').existsSync(), isTrue);
    });

    test('returns null when no db file exists', () async {
      expect(
        await DatabaseModule.createPreImportSnapshot(workDir.path),
        isNull,
      );
    });
  });

  group('backupCorruptedDatabase', () {
    test('moves db and lock files into timestamped backup', () async {
      File('${workDir.path}/pulse_track_v1.isar')
          .writeAsStringSync('corrupted');
      File('${workDir.path}/pulse_track_v1.isar.lock').writeAsStringSync('');

      await DatabaseModule.backupCorruptedDatabase(workDir.path);

      expect(File('${workDir.path}/pulse_track_v1.isar').existsSync(), isFalse);
      expect(
        File('${workDir.path}/pulse_track_v1.isar.lock').existsSync(),
        isFalse,
      );
      final backups = workDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('_corrupted_'))
          .toList();
      expect(backups, hasLength(1));
      expect(backups.single.readAsStringSync(), 'corrupted');
    });

    test('does nothing when db and lock files are absent', () async {
      await DatabaseModule.backupCorruptedDatabase(workDir.path);

      expect(workDir.listSync(), isEmpty);
    });
  });

  group('getEncryptionKey', () {
    test('generates and persists a 32-byte key when none is stored', () async {
      final key = await DatabaseModule.getEncryptionKey(workDir.path);

      expect(key, hasLength(32));
      expect(secureStore['isar_encryption_key'], isNotNull);
      expect(_b64(key), secureStore['isar_encryption_key']);
    });

    test('returns the stored key when it holds 32 bytes', () async {
      final stored = _bytes(List<int>.generate(32, (i) => i));
      secureStore['isar_encryption_key'] = _b64(stored);

      final key = await DatabaseModule.getEncryptionKey(workDir.path);

      expect(key, stored);
    });

    test('throws FormatException for non-base64 stored value', () async {
      secureStore['isar_encryption_key'] = '!!!not-base64!!!';

      expect(
        () => DatabaseModule.getEncryptionKey(workDir.path),
        throwsFormatException,
      );
    });

    test('throws FormatException for stored key with wrong length', () async {
      secureStore['isar_encryption_key'] = _b64(_bytes([1, 2, 3]));

      expect(
        () => DatabaseModule.getEncryptionKey(workDir.path),
        throwsFormatException,
      );
    });

    test('migrates a valid legacy key file and deletes it', () async {
      final legacyBytes = _bytes(List<int>.generate(32, (i) => 255 - i));
      File('${workDir.path}/pulse_track_v1.key')
          .writeAsStringSync(_b64(legacyBytes));

      final key = await DatabaseModule.getEncryptionKey(workDir.path);

      expect(key, legacyBytes);
      expect(secureStore['isar_encryption_key'], _b64(legacyBytes));
      expect(File('${workDir.path}/pulse_track_v1.key').existsSync(), isFalse);
    });

    test(
      'ignores malformed legacy key file and generates a fresh key',
      () async {
        File('${workDir.path}/pulse_track_v1.key').writeAsStringSync('short');

        final key = await DatabaseModule.getEncryptionKey(workDir.path);

        expect(key, hasLength(32));
        expect(_b64(key), secureStore['isar_encryption_key']);
      },
    );

    test('survives secure storage read failure by generating a key', () async {
      secureReadError = PlatformException(code: 'AUTH', message: 'locked');

      final key = await DatabaseModule.getEncryptionKey(workDir.path);

      expect(key, hasLength(32));
    });
  });
}
