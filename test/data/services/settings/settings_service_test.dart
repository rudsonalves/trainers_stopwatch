import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_schema.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';
import 'package:trainers_stopwatch/data/services/settings/settings_mapper.dart';
import 'package:trainers_stopwatch/data/services/settings/settings_service.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';

class _DatabaseFake extends Mock implements Database {
  List<Map<String, Object?>> rows = [];
  int insertedId = 1;
  int updatedRows = 1;
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
    return updatedRows;
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
  late SettingsService service;

  setUp(() {
    database = _DatabaseFake();
    service = SettingsService(
      databaseService: _DatabaseServiceFake(Success(database)),
      mapper: const SettingsMapper(),
    );
  });

  test('returns an explicit missing result when settings do not exist',
      () async {
    final result = await service.read();

    expect(result.isSuccess, isTrue);
    expect(result.value, isA<SettingsMissing>());
  });

  test('reads persisted settings as a domain model', () async {
    database.rows = [
      {
        'id': 1,
        'splitLength': 100.0,
        'lapLength': 400.0,
        'lengthUnit': 'yd',
        'brightness': 'light',
        'contrast': 'high',
        'language': 'pt_BR',
        'mSecondRefresh': 100,
        'showTutorial': 0,
      },
    ];

    final result = await service.read();
    final settings = (result.value! as SettingsFound).settings;

    expect(settings.splitDistance.value, 100);
    expect(settings.splitDistance.unit.symbol, 'yd');
    expect(settings.brightness, BrightnessPreference.light);
    expect(settings.showTutorial, isFalse);
  });

  test('inserts defaults and returns the generated id', () async {
    database.insertedId = 7;
    final defaults = Settings.create().value!;

    final result = await service.insert(defaults);

    expect(result.isSuccess, isTrue);
    expect(result.value!.id, 7);
    expect(database.writtenValues!['lengthUnit'], 'm');
    expect(database.writtenValues!.containsKey('dbSchemeVersion'), isFalse);
  });

  test('returns storageWriteFailed when update changes no row', () async {
    database.updatedRows = 0;

    final result = await service.update(Settings.create(id: 1).value!);

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.storageWriteFailed);
  });

  test('updates persisted settings without schema metadata', () async {
    final result = await service.update(Settings.create(id: 1).value!);

    expect(result.isSuccess, isTrue);
    expect(database.writtenValues!['id'], 1);
    expect(database.writtenValues!.containsKey('dbSchemeVersion'), isFalse);
  });

  test('propagates database opening failures', () async {
    const error = AppError(
      code: AppErrorCode.databaseUnavailable,
      message: 'unavailable',
    );
    final failingService = SettingsService(
      databaseService: _DatabaseServiceFake(const Failure(error)),
      mapper: const SettingsMapper(),
    );

    final result = await failingService.read();

    expect(result.isFailure, isTrue);
    expect(result.error, same(error));
  });
}
