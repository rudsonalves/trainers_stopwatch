import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
import '/data/services/database/database_service.dart';
import '/domain/common/history/models/history_entry.dart';
import '../database/table_attributes.dart';
import 'history_mapper.dart';

class HistoryService {
  final DatabaseService _databaseService;
  final HistoryMapper _mapper;

  const HistoryService({
    required DatabaseService databaseService,
    required HistoryMapper mapper,
  })  : _databaseService = databaseService,
        _mapper = mapper;

  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final id = await databaseResult.value!.insert(
        historyTable,
        _mapper.toMap(entry),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return HistoryEntry.create(
        id: id,
        trainingId: entry.trainingId,
        duration: entry.duration,
        comments: entry.comments,
      );
    } catch (error, stackTrace) {
      return Failure(_writeError('insert', error, stackTrace));
    }
  }

  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry) async {
    if (entry.snapshotRevision == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'An idempotent history write requires a snapshot identity.',
        ),
      );
    }

    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);
    final database = databaseResult.value!;

    try {
      final existing = await _findSnapshotWrite(database, entry);
      if (existing != null) return _sameWrite(existing, entry);

      try {
        final id = await database.insert(
          historyTable,
          _mapper.toMap(entry),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        return HistoryEntry.create(
          id: id,
          trainingId: entry.trainingId,
          duration: entry.duration,
          comments: entry.comments,
          snapshotRevision: entry.snapshotRevision,
          snapshotType: entry.snapshotType,
        );
      } catch (_) {
        final concurrent = await _findSnapshotWrite(database, entry);
        if (concurrent != null) return _sameWrite(concurrent, entry);
        rethrow;
      }
    } catch (error, stackTrace) {
      return Failure(_writeError('insert', error, stackTrace));
    }
  }

  AsyncResult<HistoryEntry> read(int id) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        historyTable,
        where: '$historyId = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return Failure(_notFound(id));
      return _mapper.fromMap(rows.first);
    } catch (error, stackTrace) {
      return Failure(_readError('read', error, stackTrace));
    }
  }

  AsyncResult<List<HistoryEntry>> readAllFromTraining(int trainingId) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        historyTable,
        where: '$historyTrainingId = ?',
        whereArgs: [trainingId],
        orderBy: historyId,
      );
      return _mapRows(rows);
    } catch (error, stackTrace) {
      return Failure(_readError('list', error, stackTrace));
    }
  }

  AsyncResult<Unit> update(HistoryEntry entry) async {
    final id = entry.id;
    if (id == null) return Failure(_missingId('update'));

    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final count = await databaseResult.value!.update(
        historyTable,
        _mapper.toMap(entry),
        where: '$historyId = ?',
        whereArgs: [id],
      );
      if (count != 1) return Failure(_notFound(id));
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(_writeError('update', error, stackTrace));
    }
  }

  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      await databaseResult.value!.transaction((transaction) async {
        final rows = await transaction.query(
          historyTable,
          where: '$historyTrainingId = ?',
          whereArgs: [trainingId],
          orderBy: historyId,
        );
        final index =
            rows.indexWhere((row) => row[historyId] == historyEntryId);
        if (index < 0) throw _notFound(historyEntryId);
        if (index == 0) {
          throw AppError(
            code: AppErrorCode.invalidData,
            message: 'The initial history entry cannot be deleted.',
            details: historyEntryId,
          );
        }

        final removedDuration = rows[index][historyDuration] as int;
        final deleted = await transaction.delete(
          historyTable,
          where: '$historyId = ?',
          whereArgs: [historyEntryId],
        );
        if (deleted != 1) throw _notFound(historyEntryId);

        if (index + 1 < rows.length) {
          final next = rows[index + 1];
          final nextId = next[historyId] as int;
          final mergedDuration =
              (next[historyDuration] as int) + removedDuration;
          final updated = await transaction.update(
            historyTable,
            {historyDuration: mergedDuration},
            where: '$historyId = ?',
            whereArgs: [nextId],
          );
          if (updated != 1) {
            throw _writeError(
              'merge history duration',
              StateError('Next history entry was not updated.'),
              StackTrace.current,
            );
          }
        }
      });
      return const Success(unit);
    } on AppError catch (error) {
      return Failure(error);
    } catch (error, stackTrace) {
      return Failure(_writeError('delete', error, stackTrace));
    }
  }

  Result<List<HistoryEntry>> _mapRows(List<Map<String, Object?>> rows) {
    final entries = <HistoryEntry>[];
    for (final row in rows) {
      final mapped = _mapper.fromMap(row);
      if (mapped.isFailure) return Failure(mapped.error!);
      entries.add(mapped.value!);
    }
    return Success(List.unmodifiable(entries));
  }

  Future<HistoryEntry?> _findSnapshotWrite(
    DatabaseExecutor database,
    HistoryEntry entry,
  ) async {
    final rows = await database.query(
      historyTable,
      where: '$historyTrainingId = ? AND $historySnapshotRevision = ?',
      whereArgs: [entry.trainingId, entry.snapshotRevision],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final mapped = _mapper.fromMap(rows.first);
    if (mapped.isFailure) throw mapped.error!;
    return mapped.value!;
  }

  Result<HistoryEntry> _sameWrite(
    HistoryEntry persisted,
    HistoryEntry requested,
  ) {
    final sameContent = persisted.trainingId == requested.trainingId &&
        persisted.snapshotRevision == requested.snapshotRevision &&
        persisted.snapshotType == requested.snapshotType &&
        persisted.duration == requested.duration &&
        persisted.comments == requested.comments;
    if (sameContent) return Success(persisted);

    return Failure(
      AppError(
        code: AppErrorCode.invalidData,
        message: 'Snapshot identity is already used by different content.',
        details: (persisted: persisted, requested: requested),
      ),
    );
  }

  AppError _notFound(int id) => AppError(
        code: AppErrorCode.storageNotFound,
        message: 'History entry not found.',
        details: id,
      );

  AppError _missingId(String operation) => AppError(
        code: AppErrorCode.invalidData,
        message: 'A persisted history id is required to $operation an entry.',
      );

  AppError _readError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) =>
      AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'Unable to $operation history entries.',
        details: (error: error, stackTrace: stackTrace),
      );

  AppError _writeError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) =>
      AppError(
        code: AppErrorCode.storageWriteFailed,
        message: 'Unable to $operation a history entry.',
        details: (error: error, stackTrace: stackTrace),
      );
}
