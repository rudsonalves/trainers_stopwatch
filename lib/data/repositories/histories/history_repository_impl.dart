import '/core/result/result.dart';
import '/data/services/histories/history_service.dart';
import '/domain/common/history/models/history_entry.dart';
import 'history_repository.dart';

final class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryService _service;
  final Map<int, List<HistoryEntry>> _cache = {};

  HistoryRepositoryImpl({required HistoryService service}) : _service = service;

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) =>
      _cache[trainingId] ?? const [];

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async {
    final result = await _service.readAllFromTraining(trainingId);
    if (result.isFailure) return Failure(result.error!);
    final snapshot = List<HistoryEntry>.unmodifiable(result.value!);
    _cache[trainingId] = snapshot;
    return Success(snapshot);
  }

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async {
    final result = await _service.insert(entry);
    if (result.isFailure) return Failure(result.error!);
    _cache[entry.trainingId] = List.unmodifiable([
      ...historiesForTraining(entry.trainingId),
      result.value!,
    ]);
    return result;
  }

  @override
  AsyncResult<Unit> update(HistoryEntry entry) async {
    final id = entry.id;
    if (id == null) return Failure(_missingId('update'));
    final result = await _service.update(entry);
    if (result.isFailure) return Failure(result.error!);
    _cache[entry.trainingId] = List.unmodifiable(
      historiesForTraining(
        entry.trainingId,
      ).map((cached) => cached.id == id ? entry : cached),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async {
    final result = await _service.deleteAndMergeNext(
      trainingId: trainingId,
      historyEntryId: historyEntryId,
    );
    if (result.isFailure) return Failure(result.error!);

    final cached = historiesForTraining(trainingId);
    final index = cached.indexWhere((entry) => entry.id == historyEntryId);
    if (index >= 0) {
      final updated = [...cached];
      final removed = updated.removeAt(index);
      if (index < updated.length) {
        final next = updated[index];
        final merged = HistoryEntry.create(
          id: next.id,
          trainingId: next.trainingId,
          duration: next.duration + removed.duration,
          comments: next.comments,
        );
        if (merged.isSuccess) updated[index] = merged.value!;
      }
      _cache[trainingId] = List.unmodifiable(updated);
    }
    return const Success(unit);
  }

  AppError _missingId(String operation) => AppError(
        code: AppErrorCode.invalidData,
        message: 'A persisted history id is required to $operation the cache.',
      );
}
