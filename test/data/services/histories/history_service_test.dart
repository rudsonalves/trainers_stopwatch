import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_schema.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';
import 'package:trainers_stopwatch/data/services/histories/history_mapper.dart';
import 'package:trainers_stopwatch/data/services/histories/history_service.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';

class _DatabaseFake extends Mock implements Database, Transaction {
  List<Map<String, Object?>> rows = [];
  int insertedId = 1;
  bool failUpdate = false;
  bool rolledBack = false;

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (whereArgs == null || whereArgs.isEmpty) return rows;
    if (where?.contains('trainingId') ?? false) {
      return rows.where((row) => row['trainingId'] == whereArgs.first).toList();
    }
    return rows.where((row) => row['id'] == whereArgs.first).toList();
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async =>
      insertedId;

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (failUpdate) throw StateError('update failed');
    final index = rows.indexWhere((row) => row['id'] == whereArgs!.first);
    if (index < 0) return 0;
    rows[index] = {...rows[index], ...values};
    return 1;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final before = rows.length;
    rows.removeWhere((row) => row['id'] == whereArgs!.first);
    return before - rows.length;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction transaction) action, {
    bool? exclusive,
  }) async {
    final snapshot = rows.map((row) => Map<String, Object?>.from(row)).toList();
    try {
      return await action(this);
    } catch (_) {
      rows = snapshot;
      rolledBack = true;
      rethrow;
    }
  }
}

class _DatabaseServiceFake extends DatabaseService {
  final Result<Database> result;

  _DatabaseServiceFake(this.result)
      : super(
          databaseDirectoryPath: () async => '',
          openDatabase: (_, options) async => result.value!,
          databaseExists: (_) async => false,
          readDatabaseVersion: (_) async => 1006,
          deleteDatabase: (_) async {},
          backupService: DatabaseBackupService(clock: DateTime.now),
          schema: const DatabaseSchema(),
        );

  @override
  AsyncResult<Database> open() async => result;
}

void main() {
  late _DatabaseFake database;
  late HistoryService service;

  Map<String, Object?> row(int id, int milliseconds) => {
        'id': id,
        'trainingId': 9,
        'duration': milliseconds,
        'comments': null,
      };

  setUp(() {
    database = _DatabaseFake();
    service = HistoryService(
      databaseService: _DatabaseServiceFake(Success(database)),
      mapper: const HistoryMapper(),
    );
  });

  test('inserts, reads, lists and updates history entries', () async {
    database.insertedId = 4;
    final entry = HistoryEntry.create(
      trainingId: 9,
      duration: const Duration(seconds: 2),
    ).value!;
    final inserted = await service.insert(entry);
    database.rows = [row(4, 2000)];

    final read = await service.read(4);
    final listed = await service.readAllFromTraining(9);
    final updated = await service.update(read.value!);

    expect(inserted.value!.id, 4);
    expect(read.value!.duration, const Duration(seconds: 2));
    expect(listed.value, hasLength(1));
    expect(updated.isSuccess, isTrue);
  });

  test('deletes an entry and transfers duration to the next entry', () async {
    database.rows = [row(1, 0), row(2, 1000), row(3, 2000)];

    final result = await service.deleteAndMergeNext(
      trainingId: 9,
      historyEntryId: 2,
    );

    expect(result.isSuccess, isTrue);
    expect(database.rows.map((item) => item['id']), [1, 3]);
    expect(database.rows.last['duration'], 3000);
  });

  test('deletes the last entry without requiring a next entry', () async {
    database.rows = [row(1, 0), row(2, 1000)];

    final result = await service.deleteAndMergeNext(
      trainingId: 9,
      historyEntryId: 2,
    );

    expect(result.isSuccess, isTrue);
    expect(database.rows.map((item) => item['id']), [1]);
  });

  test('rejects deletion of the initial entry', () async {
    database.rows = [row(1, 0), row(2, 1000)];

    final result = await service.deleteAndMergeNext(
      trainingId: 9,
      historyEntryId: 1,
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(database.rows, hasLength(2));
  });

  test('returns storageNotFound for an entry outside the training', () async {
    database.rows = [row(1, 0), row(2, 1000)];

    final result = await service.deleteAndMergeNext(
      trainingId: 9,
      historyEntryId: 7,
    );

    expect(result.error!.code, AppErrorCode.storageNotFound);
  });

  test('rolls back deletion when merging the next duration fails', () async {
    database.rows = [row(1, 0), row(2, 1000), row(3, 2000)];
    database.failUpdate = true;

    final result = await service.deleteAndMergeNext(
      trainingId: 9,
      historyEntryId: 2,
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.storageWriteFailed);
    expect(database.rolledBack, isTrue);
    expect(database.rows.map((item) => item['id']), [1, 2, 3]);
    expect(database.rows.last['duration'], 2000);
  });
}
