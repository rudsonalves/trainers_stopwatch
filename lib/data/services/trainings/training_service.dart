import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
import '/data/services/database/database_service.dart';
import '/domain/common/training/models/training.dart';
import '../database/table_attributes.dart';
import 'training_mapper.dart';

class TrainingService {
  final DatabaseService _databaseService;
  final TrainingMapper _mapper;

  const TrainingService({
    required DatabaseService databaseService,
    required TrainingMapper mapper,
  })  : _databaseService = databaseService,
        _mapper = mapper;

  AsyncResult<Training> insert(Training training) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final id = await databaseResult.value!.insert(
        trainingTable,
        _mapper.toMap(training),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return _withId(training, id);
    } catch (error, stackTrace) {
      return Failure(_writeError('insert', error, stackTrace));
    }
  }

  AsyncResult<Training> read(int id) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        trainingTable,
        where: '$trainingId = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return Failure(_notFound(id));
      return _mapper.fromMap(rows.first);
    } catch (error, stackTrace) {
      return Failure(_readError('read', error, stackTrace));
    }
  }

  AsyncResult<List<Training>> readAllFromUser(int userId) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        trainingTable,
        where: '$trainingUserId = ?',
        whereArgs: [userId],
        orderBy: trainingDate,
      );
      final trainings = <Training>[];
      for (final row in rows) {
        final mapped = _mapper.fromMap(row);
        if (mapped.isFailure) return Failure(mapped.error!);
        trainings.add(mapped.value!);
      }
      return Success(List.unmodifiable(trainings));
    } catch (error, stackTrace) {
      return Failure(_readError('list', error, stackTrace));
    }
  }

  AsyncResult<Unit> update(Training training) async {
    final id = training.id;
    if (id == null) return Failure(_missingId('update'));

    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final count = await databaseResult.value!.update(
        trainingTable,
        _mapper.toMap(training),
        where: '$trainingId = ?',
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
        trainingTable,
        where: '$trainingId = ?',
        whereArgs: [id],
      );
      if (count != 1) return Failure(_notFound(id));
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(_writeError('delete', error, stackTrace));
    }
  }

  Result<Training> _withId(Training training, int id) => Training.create(
        id: id,
        userId: training.userId,
        date: training.date,
        comments: training.comments,
        splitDistance: training.splitDistance,
        lapDistance: training.lapDistance,
        maxLaps: training.maxLaps,
        speedUnit: training.speedUnit,
      );

  AppError _notFound(int id) => AppError(
        code: AppErrorCode.storageNotFound,
        message: 'Training not found.',
        details: id,
      );

  AppError _missingId(String operation) => AppError(
        code: AppErrorCode.invalidData,
        message:
            'A persisted training id is required to $operation a training.',
      );

  AppError _readError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) =>
      AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'Unable to $operation trainings.',
        details: (error: error, stackTrace: stackTrace),
      );

  AppError _writeError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) =>
      AppError(
        code: AppErrorCode.storageWriteFailed,
        message: 'Unable to $operation a training.',
        details: (error: error, stackTrace: stackTrace),
      );
}
