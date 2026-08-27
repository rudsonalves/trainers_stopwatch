import '/core/result/result.dart';
import '/data/repositories/histories/history_repository.dart';
import '/domain/common/history/models/history_entry.dart';
import '/domain/common/stopwatch/models/stopwatch_snapshot.dart';

class PersistStopwatchSnapshotUseCase {
  final HistoryRepository _historyRepository;

  const PersistStopwatchSnapshotUseCase({
    required HistoryRepository historyRepository,
  }) : _historyRepository = historyRepository;

  AsyncResult<HistoryEntry> execute({
    required int trainingId,
    required int snapshotRevision,
    required StopwatchSnapshot snapshot,
    String? comments,
  }) async {
    final entry = HistoryEntry.create(
      trainingId: trainingId,
      duration: switch (snapshot) {
        SplitSnapshot(:final splitDuration) => splitDuration,
        LapSnapshot(:final splitDuration) => splitDuration,
        FinishSnapshot(:final finalSplitDuration) => finalSplitDuration,
      },
      comments: comments,
      snapshotRevision: snapshotRevision,
      snapshotType: switch (snapshot) {
        SplitSnapshot() => HistorySnapshotType.split,
        LapSnapshot() => HistorySnapshotType.lap,
        FinishSnapshot() => HistorySnapshotType.finish,
      },
    );
    if (entry.isFailure) return Failure(entry.error!);
    return _historyRepository.insertIdempotent(entry.value!);
  }
}
