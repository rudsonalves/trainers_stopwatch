import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_schema.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';
import 'package:trainers_stopwatch/data/services/users/user_mapper.dart';
import 'package:trainers_stopwatch/data/services/users/user_service.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

class _DatabaseFake extends Mock implements Database {
  List<Map<String, Object?>> rows = [];
  List<Map<String, Object?>> rawRows = [];
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
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async =>
      rawRows;

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
  late UserService service;

  setUp(() {
    database = _DatabaseFake();
    service = UserService(
      databaseService: _DatabaseServiceFake(Success(database)),
      mapper: const UserMapper(),
    );
  });

  test('inserts a user and returns its generated id', () async {
    database.insertedId = 7;

    final result = await service.insert(
      const User(name: 'Ana', email: 'ana@example.com'),
    );

    expect(result.isSuccess, isTrue);
    expect(result.value!.id, 7);
    expect(database.writtenValues!['name'], 'Ana');
  });

  test('reads and maps a user by id', () async {
    database.rows = [
      {
        'id': 2,
        'name': 'Bia',
        'email': 'bia@example.com',
        'phone': null,
        'photo': 'bia.png',
      },
    ];

    final result = await service.read(2);

    expect(result.isSuccess, isTrue);
    expect(result.value!.name, 'Bia');
    expect(result.value!.photoReference, 'bia.png');
  });

  test('returns storageNotFound for an absent user', () async {
    final result = await service.read(99);

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.storageNotFound);
  });

  test('lists users in the order delivered by persistence', () async {
    database.rows = [
      {'id': 1, 'name': 'Ana', 'email': 'a@a.com'},
      {'id': 2, 'name': 'Bia', 'email': 'b@b.com'},
    ];

    final result = await service.readAll();

    expect(result.value!.map((user) => user.name), ['Ana', 'Bia']);
    expect(
        () => result.value!.add(result.value!.first), throwsUnsupportedError);
  });

  test('updates and deletes persisted users', () async {
    const user = User(id: 1, name: 'Ana', email: 'new@example.com');

    final updateResult = await service.update(user);
    final deleteResult = await service.delete(1);

    expect(updateResult.isSuccess, isTrue);
    expect(deleteResult.isSuccess, isTrue);
    expect(database.writtenValues!['email'], 'new@example.com');
  });

  test('rejects update without a persisted id', () async {
    final result = await service.update(
      const User(name: 'Ana', email: 'ana@example.com'),
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
  });

  test('returns storageNotFound when delete changes no row', () async {
    database.affectedRows = 0;

    final result = await service.delete(4);

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.storageNotFound);
  });

  test('lists only non-null photo references', () async {
    database.rawRows = [
      {'photo': 'ana.png'},
      {'photo': null},
      {'photo': 'bia.png'},
    ];

    final result = await service.readPhotoReferences();

    expect(result.value, ['ana.png', 'bia.png']);
  });

  test('rejects invalid persisted user data', () async {
    database.rows = [
      {'id': 1, 'name': 'Ana'},
    ];

    final result = await service.read(1);

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
  });
}
