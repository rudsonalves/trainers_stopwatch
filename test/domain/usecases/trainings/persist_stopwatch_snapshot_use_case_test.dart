import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/stopwatch/models/stopwatch_snapshot.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';

class _HistoryRepositoryFake implements HistoryRepository {
  HistoryEntry? inserted;

  @override
  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry) async {
    inserted = entry;
    return HistoryEntry.create(
      id: 15,
      trainingId: entry.trainingId,
      duration: entry.duration,
      comments: entry.comments,
      snapshotRevision: entry.snapshotRevision,
      snapshotType: entry.snapshotType,
    );
  }

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) => const [];

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async =>
      const Success(unit);

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async => Success(entry);

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async =>
      const Success([]);

  @override
  AsyncResult<Unit> update(HistoryEntry entry) async => const Success(unit);
}

void main() {
  test('maps snapshot content and identity to an idempotent history write',
      () async {
    final repository = _HistoryRepositoryFake();
    final useCase = PersistStopwatchSnapshotUseCase(
      historyRepository: repository,
    );
    final snapshot = LapSnapshot.create(
      elapsed: const Duration(seconds: 10),
      splitDuration: const Duration(seconds: 4),
      lapDuration: const Duration(seconds: 10),
      lapCount: 1,
      splitCount: 2,
    ).value!;

    final result = await useCase.execute(
      trainingId: 8,
      snapshotRevision: 5,
      snapshot: snapshot,
      comments: 'lap snapshot',
    );

    expect(result.isSuccess, isTrue);
    expect(repository.inserted!.trainingId, 8);
    expect(repository.inserted!.snapshotRevision, 5);
    expect(repository.inserted!.snapshotType, HistorySnapshotType.lap);
    expect(repository.inserted!.duration, const Duration(seconds: 4));
    expect(repository.inserted!.comments, 'lap snapshot');
  });
}
