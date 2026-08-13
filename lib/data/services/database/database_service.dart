import 'dart:developer';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
import 'table_attributes.dart';
import 'database_backup_service.dart';
import 'database_schema.dart';

typedef DatabaseDirectoryPath = Future<String> Function();
typedef OpenLocalDatabase = Future<Database> Function(
  String path,
  OpenDatabaseOptions options,
);
typedef LocalDatabaseExists = Future<bool> Function(String path);
typedef ReadLocalDatabaseVersion = Future<int> Function(String path);
typedef DeleteLocalDatabase = Future<void> Function(String path);

class DatabaseService {
  final DatabaseDirectoryPath _databaseDirectoryPath;
  final OpenLocalDatabase _openDatabase;
  final LocalDatabaseExists _databaseExists;
  final ReadLocalDatabaseVersion _readDatabaseVersion;
  final DeleteLocalDatabase _deleteDatabase;
  final DatabaseBackupService _backupService;
  final DatabaseSchema _schema;

  Database? _database;
  Future<Result<Database>>? _opening;

  DatabaseService({
    required DatabaseDirectoryPath databaseDirectoryPath,
    required OpenLocalDatabase openDatabase,
    required LocalDatabaseExists databaseExists,
    required ReadLocalDatabaseVersion readDatabaseVersion,
    required DeleteLocalDatabase deleteDatabase,
    required DatabaseBackupService backupService,
    required DatabaseSchema schema,
  })  : _databaseDirectoryPath = databaseDirectoryPath,
        _openDatabase = openDatabase,
        _databaseExists = databaseExists,
        _readDatabaseVersion = readDatabaseVersion,
        _deleteDatabase = deleteDatabase,
        _backupService = backupService,
        _schema = schema;

  bool get isOpen => _database?.isOpen ?? false;

  AsyncResult<Database> open() {
    final database = _database;
    if (database != null && database.isOpen) {
      return Future.value(Success(database));
    }

    return _opening ??= _open().whenComplete(() => _opening = null);
  }

  AsyncResult<Unit> close() async {
    final database = _database;
    if (database == null) return const Success(unit);

    try {
      if (database.isOpen) await database.close();
      _database = null;
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.databaseUnavailable,
          message: 'Unable to close the application database.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }

  AsyncResult<Database> _open() async {
    try {
      final directoryPath = await _databaseDirectoryPath();
      final databasePath = path.join(directoryPath, dbName);
      log('Database path: $databasePath');

      await _replaceLegacyDatabase(databasePath);

      final database = await _openDatabase(
        databasePath,
        OpenDatabaseOptions(
          version: dbVersion,
          onConfigure: _configure,
          onCreate: _schema.create,
        ),
      );
      _database = database;
      log('Database opened successfully');
      return Success(database);
    } on AppError catch (error) {
      return Failure(error);
    } catch (error, stackTrace) {
      log('Open database error: $error', stackTrace: stackTrace);
      return Failure(
        AppError(
          code: AppErrorCode.databaseUnavailable,
          message: 'Unable to open the application database.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }

  Future<void> _configure(Database database) =>
      database.execute('PRAGMA foreign_keys = ON');

  Future<void> _replaceLegacyDatabase(String databasePath) async {
    if (!await _databaseExists(databasePath)) return;

    var mustReplace = false;
    try {
      mustReplace = await _readDatabaseVersion(databasePath) != dbVersion;
    } catch (_) {
      mustReplace = true;
    }
    if (!mustReplace) return;

    final backup = await _backupService.preserve(databasePath);
    if (backup.isFailure) throw backup.error!;

    try {
      await _deleteDatabase(databasePath);
    } catch (error, stackTrace) {
      throw AppError(
        code: AppErrorCode.migrationFailed,
        message: 'Unable to replace the incompatible application database.',
        details: (
          error: error,
          stackTrace: stackTrace,
          backupPath: backup.value,
        ),
      );
    }
  }
}
