import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/crash_reporter.dart';
import '../../../features/workout/infrastructure/models/device_profile_dto.dart';
import '../../../features/workout/infrastructure/models/workout_session_dto.dart';
import '../../../features/settings/infrastructure/models/user_settings_dto.dart';

/// Manages Isar initialization, AES key provisioning, and crash-recovery.
class DatabaseModule {
  /// Versioned database name.
  static const String dbName = 'pulse_track_v1';

  static const List<String> _legacyDbNames = ['pulse_track_v0'];

  static const String _encryptionKeyKey = 'isar_encryption_key';
  static const String _legacyEncryptionKeyFileName = 'pulse_track_v1.key';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Retrieves or generates a 256-bit AES key.
  static Future<Uint8List> getEncryptionKey([String? directoryPath]) async {
    String? stored;
    try {
      stored = await _secureStorage.read(key: _encryptionKeyKey);
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[DatabaseModule] Failed to read encryption key from secure storage',
        fatal: false,
      );
    }

    if (stored != null && stored.isNotEmpty) {
      try {
        final decoded = base64Decode(stored);
        if (decoded.length == 32) {
          return Uint8List.fromList(decoded);
        }
        throw FormatException(
          'Malformed stored encryption key: expected 32 bytes, got ${decoded.length}',
        );
      } catch (e) {
        throw FormatException('Malformed stored encryption key: $e');
      }
    }

    File? legacyKeyFile;
    try {
      final dirPath =
          directoryPath ?? (await getApplicationDocumentsDirectory()).path;
      legacyKeyFile = File('$dirPath/$_legacyEncryptionKeyFileName');

      if (await legacyKeyFile.exists()) {
        final content = (await legacyKeyFile.readAsString()).trim();
        if (content.isNotEmpty) {
          final decoded = base64Decode(content);
          if (decoded.length == 32) {
            try {
              await _secureStorage.write(
                key: _encryptionKeyKey,
                value: content,
              );
            } catch (e, stack) {
              await AppCrashReporter.recordError(
                e,
                stack,
                reason: '[DatabaseModule] Failed to migrate legacy key to secure storage',
                fatal: false,
              );
            }
            try {
              await legacyKeyFile.delete();
            } catch (e, stack) {
              await AppCrashReporter.recordError(
                e,
                stack,
                reason: '[DatabaseModule] Failed to delete legacy key file after migration',
                fatal: false,
              );
            }
            return Uint8List.fromList(decoded);
          }
        }
      }
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[DatabaseModule] Error checking legacy encryption key file',
        fatal: false,
      );
    }

    final key = Uint8List.fromList(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    final base64Key = base64Encode(key);

    try {
      await _secureStorage.write(key: _encryptionKeyKey, value: base64Key);
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[DatabaseModule] Failed to write new encryption key to secure storage',
        fatal: false,
      );
    }

    return key;
  }

  /// Opens and returns an Isar instance with all registered schemas.
  static Future<Isar> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    final existingInstance = Isar.getInstance(dbName);
    if (existingInstance != null && existingInstance.isOpen) {
      return existingInstance;
    }

    await getEncryptionKey();

    await _quarantineLegacyDatabase(dir.path);

    try {
      return await _openIsar(dir.path);
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[DatabaseModule] Failed to open Isar database',
        fatal: false,
      );

      try {
        await backupCorruptedDatabase(dir.path);
      } catch (backupError, backupStack) {
        await AppCrashReporter.recordError(
          backupError,
          backupStack,
          reason: '[DatabaseModule] Database backup during recovery failed',
          fatal: false,
        );
      }

      try {
        return await _openIsar(dir.path);
      } catch (retryError, retryStack) {
        await AppCrashReporter.recordError(
          retryError,
          retryStack,
          reason: '[DatabaseModule] Recovery re-opening failed',
          fatal: true,
        );
        rethrow;
      }
    }
  }

  /// Verifies database integrity on app resume.
  static Future<({Isar instance, bool reopened})>
  ensureInstanceIntegrity() async {
    try {
      final instance = Isar.getInstance(dbName);
      if (instance == null || !instance.isOpen) {
        if (kDebugMode) {
          debugPrint(
            '[DatabaseModule] Isar instance invalid or closed on app resumption. Re-initializing...',
          );
        }
        return (instance: await initialize(), reopened: true);
      }
      return (instance: instance, reopened: false);
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[DatabaseModule] Error verifying Isar instance integrity on resumption',
        fatal: false,
      );
      return (instance: await initialize(), reopened: true);
    }
  }

  static Future<Isar> _openIsar(String directoryPath) {
    return Isar.open(
      [DeviceProfileDtoSchema, WorkoutSessionDtoSchema, UserSettingsDtoSchema],
      directory: directoryPath,
      name: dbName,
      compactOnLaunch: const CompactCondition(
        minFileSize: 10 * 1024 * 1024,
        minRatio: 1.25,
      ),
    );
  }

  @visibleForTesting
  static Future<void> quarantineLegacyDatabaseForTesting(
    String directoryPath,
  ) => _quarantineLegacyDatabase(directoryPath);

  static Future<void> _quarantineLegacyDatabase(String directoryPath) async {
    for (final legacyName in _legacyDbNames) {
      final legacyFile = File('$directoryPath/$legacyName.isar');
      if (!await legacyFile.exists()) continue;
      final quarantinePath = '$directoryPath/$legacyName.legacy.bak';
      try {
        await legacyFile.rename(quarantinePath);
        if (kDebugMode) {
          debugPrint(
            '[DatabaseModule] Quarantined legacy database to $quarantinePath',
          );
        }
      } catch (e) {
        try {
          await legacyFile.copy(quarantinePath);
          await legacyFile.delete();
        } catch (fallbackError, fallbackStack) {
          await AppCrashReporter.recordError(
            fallbackError,
            fallbackStack,
            reason: '[DatabaseModule] Failed to quarantine legacy database',
            fatal: false,
          );
        }
      }
    }
  }

  /// Creates a pre-import snapshot backup.
  static Future<String?> createPreImportSnapshot([
    String? directoryPath,
  ]) async {
    try {
      final path =
          directoryPath ?? (await getApplicationDocumentsDirectory()).path;
      final dbFile = File('$path/$dbName.isar');
      if (await dbFile.exists()) {
        final backupPath = '$path/${dbName}_pre_import.isar.bak';
        await dbFile.copy(backupPath);
        if (kDebugMode) {
          debugPrint(
            '[DatabaseModule] Pre-import snapshot created at $backupPath',
          );
        }
        return backupPath;
      }
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason: '[DatabaseModule] Failed to create pre-import snapshot',
        fatal: false,
      );
    }
    return null;
  }

  @visibleForTesting
  static Future<void> backupCorruptedDatabase(String directoryPath) async {
    final dbFile = File('$directoryPath/$dbName.isar');
    final lockFile = File('$directoryPath/$dbName.isar.lock');

    if (await dbFile.exists()) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath =
          '$directoryPath/${dbName}_corrupted_$timestamp.isar.bak';
      await dbFile.copy(backupPath);
      await dbFile.delete();
      if (kDebugMode) {
        debugPrint(
          '[DatabaseModule] Corrupted database backed up to $backupPath',
        );
      }
    }

    if (await lockFile.exists()) {
      await lockFile.delete();
    }
  }
}
