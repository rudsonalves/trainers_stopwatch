import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_schema.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';
import 'package:trainers_stopwatch/data/services/trainings/training_mapper.dart';
import 'package:trainers_stopwatch/data/services/trainings/training_service.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';

class _DatabaseFake extends Mock implements Database {
  List<Map<String, Object?>> rows = [];
  int insertedId = 1;
  int affectedRows = 1;
  Map<String, Object?>? writtenValues;

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
  }) async =>
      rows;

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    writtenValues = values;
    return insertedId;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    writtenValues = values;
    return affectedRows;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async =>
      affectedRows;
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
  late TrainingService service;
  final date = DateTime(2026, 8, 13);

  Training training({int? id}) => Training.create(
        id: id,
        userId: 3,
        date: date,
        comments: 'intervals',
      ).value!;

  Map<String, Object?> row({
    String distanceUnit = 'm',
    String speedUnit = 'm/s',
  }) =>
      {
        'id': 4,
        'userId': 3,
        'date': date.millisecondsSinceEpoch,
        'comments': 'intervals',
        'splitLength': 200.0,
        'lapLength': 1000.0,
        'maxlaps': 5,
        'distanceUnit': distanceUnit,
        'speedUnit': speedUnit,
      };

  setUp(() {
    database = _DatabaseFake();
    service = TrainingService(
      databaseService: _DatabaseServiceFake(Success(database)),
      mapper: const TrainingMapper(),
    );
  });

  test('inserts a training and returns its generated id', () async {
    database.insertedId = 7;

    final result = await service.insert(training());

    expect(result.isSuccess, isTrue);
    expect(result.value!.id, 7);
    expect(database.writtenValues!['date'], date.millisecondsSinceEpoch);
    expect(database.writtenValues!.containsKey('color'), isFalse);
  });

  test('reads a typed training by id', () async {
    database.rows = [row()];

    final result = await service.read(4);

    expect(result.isSuccess, isTrue);
    expect(result.value!.splitDistance.unit, DistanceUnit.meter);
    expect(result.value!.speedUnit, SpeedUnit.metersPerSecond);
    expect(result.value!.maxLaps, 5);
  });

  test('lists trainings for a user as an immutable collection', () async {
    database.rows = [
      row(),
      {...row(), 'id': 5}
    ];

    final result = await service.readAllFromUser(3);

    expect(result.value, hasLength(2));
    expect(
      () => result.value!.add(result.value!.first),
      throwsUnsupportedError,
    );
  });

  test('updates and deletes a persisted training', () async {
    final updateResult = await service.update(training(id: 4));
    final deleteResult = await service.delete(4);

    expect(updateResult.isSuccess, isTrue);
    expect(deleteResult.isSuccess, isTrue);
  });

  test('returns storageNotFound when a training does not exist', () async {
    final readResult = await service.read(99);
    database.affectedRows = 0;
    final deleteResult = await service.delete(99);

    expect(readResult.error!.code, AppErrorCode.storageNotFound);
    expect(deleteResult.error!.code, AppErrorCode.storageNotFound);
  });

  test('rejects update without a persisted id', () async {
    final result = await service.update(training());

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
  });

  test('rejects an unknown persisted distance unit', () async {
    database.rows = [row(distanceUnit: 'league')];

    final result = await service.read(4);

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
  });

  test('rejects an unknown persisted speed unit', () async {
    database.rows = [row(speedUnit: 'warp')];

    final result = await service.read(4);

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
  });

  test('preserves imperial units without rounding', () async {
    final imperial = Training.create(
      userId: 3,
      date: date,
      splitDistance: Distance.create(
        value: 220,
        unit: DistanceUnit.yard,
      ).value!,
      lapDistance: Distance.create(
        value: 1760,
        unit: DistanceUnit.yard,
      ).value!,
      speedUnit: SpeedUnit.milesPerHour,
    ).value!;

    final result = await service.insert(imperial);

    expect(result.isSuccess, isTrue);
    expect(database.writtenValues!['distanceUnit'], 'yd');
    expect(database.writtenValues!['speedUnit'], 'mph');
    expect(database.writtenValues!['splitLength'], 220.0);
  });
}
