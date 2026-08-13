import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
import '/data/services/database/database_service.dart';
import '/domain/common/user/models/user.dart';
import '../database/table_attributes.dart';
import '../database/table_sql_scripts.dart';
import 'user_mapper.dart';

class UserService {
  final DatabaseService _databaseService;
  final UserMapper _mapper;

  const UserService({
    required DatabaseService databaseService,
    required UserMapper mapper,
  })  : _databaseService = databaseService,
        _mapper = mapper;

  AsyncResult<User> insert(User user) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final id = await databaseResult.value!.insert(
        userTable,
        _mapper.toMap(user),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return Success(
        User(
          id: id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          photoReference: user.photoReference,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(_writeError('insert', error, stackTrace));
    }
  }

  AsyncResult<User> read(int id) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        userTable,
        where: '$userId = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) {
        return Failure(_notFound(id));
      }
      return _mapper.fromMap(rows.first);
    } catch (error, stackTrace) {
      return Failure(_readError('read', error, stackTrace));
    }
  }

  AsyncResult<List<User>> readAll() async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        userTable,
        orderBy: userName,
      );
      final users = <User>[];
      for (final row in rows) {
        final mapped = _mapper.fromMap(row);
        if (mapped.isFailure) return Failure(mapped.error!);
        users.add(mapped.value!);
      }
      return Success(List.unmodifiable(users));
    } catch (error, stackTrace) {
      return Failure(_readError('list', error, stackTrace));
    }
  }

  AsyncResult<Unit> update(User user) async {
    final id = user.id;
    if (id == null) return Failure(_missingId('update'));

    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final count = await databaseResult.value!.update(
        userTable,
        _mapper.toMap(user),
        where: '$userId = ?',
        whereArgs: [id],
      );
      if (count != 1) return Failure(_notFound(id));
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(_writeError('update', error, stackTrace));
    }
  }

  AsyncResult<Unit> delete(int id) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final count = await databaseResult.value!.delete(
        userTable,
        where: '$userId = ?',
        whereArgs: [id],
      );
      if (count != 1) return Failure(_notFound(id));
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(_writeError('delete', error, stackTrace));
    }
  }

  AsyncResult<List<String>> readPhotoReferences() async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.rawQuery(getUserImagesListSQL);
      final references = rows
          .map((row) => row[userPhoto])
          .whereType<String>()
          .toList(growable: false);
      return Success(List.unmodifiable(references));
    } catch (error, stackTrace) {
      return Failure(_readError('read photos', error, stackTrace));
    }
  }

  AppError _notFound(int id) => AppError(
        code: AppErrorCode.storageNotFound,
        message: 'User not found.',
        details: id,
      );

  AppError _missingId(String operation) => AppError(
        code: AppErrorCode.invalidData,
        message: 'A persisted user id is required to $operation a user.',
      );

  AppError _readError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) =>
      AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'Unable to $operation users.',
        details: (error: error, stackTrace: stackTrace),
      );

  AppError _writeError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) =>
      AppError(
        code: AppErrorCode.storageWriteFailed,
        message: 'Unable to $operation a user.',
        details: (error: error, stackTrace: stackTrace),
      );
}
