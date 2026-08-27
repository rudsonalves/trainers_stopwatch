import '/core/result/result.dart';
import '/domain/common/history/models/history_entry.dart';

abstract interface class HistoryRepository {
  List<HistoryEntry> historiesForTraining(int trainingId);

  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId);
  AsyncResult<HistoryEntry> insert(HistoryEntry entry);
  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry);
  AsyncResult<Unit> update(HistoryEntry entry);
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  });
}
