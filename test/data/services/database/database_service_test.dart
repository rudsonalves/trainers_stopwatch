import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_schema.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';

class _DatabaseMock extends Mock implements Database {
  bool open = true;
  final executedSql = <String>[];

  @override
  bool get isOpen => open;

  @override
  Future<void> close() async => open = false;

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    executedSql.add(sql);
  }
}

class _DatabaseSchemaMock extends DatabaseSchema {
  int createCalls = 0;
  int upgradeCalls = 0;

  @override
  Future<void> create(Database database, int version) async => createCalls++;

  @override
  Future<void> upgrade(
      Database database, int oldVersion, int newVersion) async {
    upgradeCalls++;
  }
}

void main() {
  late _DatabaseMock database;
  late _DatabaseSchemaMock schema;
  late OpenDatabaseOptions capturedOptions;
  late int openCalls;

  setUp(() {
    database = _DatabaseMock();
    schema = _DatabaseSchemaMock();
    openCalls = 0;
  });

  DatabaseService createService() => DatabaseService(
        databaseDirectoryPath: () async => '/tmp/trainers-stopwatch-test',
        openDatabase: (path, options) async {
          openCalls++;
          capturedOptions = options;
          return database;
        },
        databaseExists: (_) async => false,
        readDatabaseVersion: (_) async => 1006,
        deleteDatabase: (_) async {},
        backupService: DatabaseBackupService(
          clock: () => DateTime.utc(2026, 8, 13),
        ),
        schema: schema,
      );

  test('reuses the open connection', () async {
    final service = createService();

    final first = await service.open();
    final second = await service.open();

    expect(first.isSuccess, isTrue);
    expect(second.isSuccess, isTrue);
    expect(identical(first.value, second.value), isTrue);
    expect(openCalls, 1);
  });

  test('configures foreign keys on every opened connection', () async {
    final service = createService();
    await service.open();

    await capturedOptions.onConfigure!(database);

    expect(database.executedSql, ['PRAGMA foreign_keys = ON']);
  });

  test('delegates schema creation to DatabaseSchema', () async {
    final service = createService();
    await service.open();

    await capturedOptions.onCreate!(database, 1);

    expect(schema.createCalls, 1);
    expect(capturedOptions.version, 1008);
  });

  test('upgrades version 1006 without replacing the database', () async {
    var deleted = false;
    final service = DatabaseService(
      databaseDirectoryPath: () async => '/tmp/trainers-stopwatch-test',
      openDatabase: (path, options) async {
        capturedOptions = options;
        return database;
      },
      databaseExists: (_) async => true,
      readDatabaseVersion: (_) async => 1006,
      deleteDatabase: (_) async => deleted = true,
      backupService: DatabaseBackupService(
        clock: () => DateTime.utc(2026, 8, 13),
      ),
      schema: schema,
    );

    final result = await service.open();
    await capturedOptions.onUpgrade!(database, 1006, 1008);

    expect(result.isSuccess, isTrue);
    expect(deleted, isFalse);
    expect(schema.upgradeCalls, 1);
  });

  test('converts open failures to databaseUnavailable', () async {
    final service = DatabaseService(
      databaseDirectoryPath: () async => throw StateError('path unavailable'),
      openDatabase: (unusedPath, unusedOptions) async => database,
      databaseExists: (_) async => false,
      readDatabaseVersion: (_) async => 1007,
      deleteDatabase: (_) async {},
      backupService: DatabaseBackupService(
        clock: () => DateTime.utc(2026, 8, 13),
      ),
      schema: schema,
    );

    final result = await service.open();

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.databaseUnavailable);
  });

  test('closes the connection and allows a new opening', () async {
    final service = createService();
    await service.open();

    final closeResult = await service.close();
    await service.open();

    expect(closeResult.isSuccess, isTrue);
    expect(database.open, isFalse);
    expect(openCalls, 2);
  });

  test('backs up and replaces a database from a different version', () async {
    final directory = await Directory.systemTemp.createTemp('stopwatch-db-');
    addTearDown(() => directory.delete(recursive: true));
    final databaseFile = File('${directory.path}/stopwatch.db');
    await databaseFile.writeAsString('legacy-data');

    final service = DatabaseService(
      databaseDirectoryPath: () async => directory.path,
      openDatabase: (path, options) async => database,
      databaseExists: (_) async => true,
      readDatabaseVersion: (_) async => 1,
      deleteDatabase: (path) => File(path).delete(),
      backupService: DatabaseBackupService(
        clock: () => DateTime.utc(2026, 8, 13, 12),
      ),
      schema: schema,
    );

    final result = await service.open();
    final files = await directory.list().map((item) => item.path).toList();

    expect(result.isSuccess, isTrue);
    expect(await databaseFile.exists(), isFalse);
    expect(files.single, contains('stopwatch.db.backup-2026-08-13T12-00-00'));
    expect(await File(files.single).readAsString(), 'legacy-data');
  });

  test('upgrades version 1007 without replacing the database', () async {
    var deleted = false;
    final service = DatabaseService(
      databaseDirectoryPath: () async => '/tmp/trainers-stopwatch-test',
      openDatabase: (path, options) async => database,
      databaseExists: (_) async => true,
      readDatabaseVersion: (_) async => 1007,
      deleteDatabase: (_) async => deleted = true,
      backupService: DatabaseBackupService(
        clock: () => DateTime.utc(2026, 8, 13),
      ),
      schema: schema,
    );

    final result = await service.open();

    expect(result.isSuccess, isTrue);
    expect(deleted, isFalse);
  });

  test('does not replace a database already at the current version', () async {
    var deleted = false;
    final service = DatabaseService(
      databaseDirectoryPath: () async => '/tmp/trainers-stopwatch-test',
      openDatabase: (path, options) async => database,
      databaseExists: (_) async => true,
      readDatabaseVersion: (_) async => 1008,
      deleteDatabase: (_) async => deleted = true,
      backupService: DatabaseBackupService(
        clock: () => DateTime.utc(2026, 8, 13),
      ),
      schema: schema,
    );

    final result = await service.open();

    expect(result.isSuccess, isTrue);
    expect(deleted, isFalse);
  });
}
