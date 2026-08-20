import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/training/events/training_event.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/ui/pages/history/viewmodel/history_view_model.dart';

const readFailure = AppError(
  code: AppErrorCode.storageReadFailed,
  message: 'read failed',
);
const writeFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'write failed',
);

class _HistoryRepositoryFake implements HistoryRepository {
  List<HistoryEntry> stored = const [];
  List<HistoryEntry> _cache = const [];
  bool failLoad = false;
  bool failUpdate = false;
  bool failDelete = false;
  int loadCalls = 0;

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) =>
      _cache.where((entry) => entry.trainingId == trainingId).toList(
            growable: false,
          );

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async {
    loadCalls++;
    if (failLoad) return const Failure(readFailure);
    _cache = List.unmodifiable(
      stored.where((entry) => entry.trainingId == trainingId),
    );
    return Success(_cache);
  }

  @override
  AsyncResult<Unit> update(HistoryEntry entry) async {
    if (failUpdate) return const Failure(writeFailure);
    _cache = List.unmodifiable(
      _cache.map((current) => current.id == entry.id ? entry : current),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async {
    if (failDelete) return const Failure(writeFailure);
    final updated = [..._cache];
    final index = updated.indexWhere((entry) => entry.id == historyEntryId);
    final removed = updated.removeAt(index);
    final next = updated[index];
    updated[index] = HistoryEntry.create(
      id: next.id,
      trainingId: next.trainingId,
      duration: next.duration + removed.duration,
      comments: next.comments,
    ).value!;
    _cache = List.unmodifiable(updated);
    return const Success(unit);
  }

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async => Success(entry);
}

void main() {
  late _HistoryRepositoryFake repository;
  late HistoryViewModel viewModel;

  final training = Training.create(
    id: 7,
    userId: 1,
    date: DateTime(2026, 8, 20),
  ).value!;

  HistoryEntry history(int id, Duration duration, {String? comments}) =>
      HistoryEntry.create(
        id: id,
        trainingId: 7,
        duration: duration,
        comments: comments,
      ).value!;

  setUp(() {
    repository = _HistoryRepositoryFake()
      ..stored = [
        history(1, Duration.zero, comments: 'start'),
        history(2, const Duration(seconds: 10)),
        history(3, const Duration(seconds: 11)),
        history(4, const Duration(seconds: 12)),
        history(5, const Duration(seconds: 13)),
        history(6, const Duration(seconds: 14), comments: 'lap'),
      ];
    viewModel = HistoryViewModel(
      training: training,
      historyRepository: repository,
    );
    addTearDown(viewModel.dispose);
  });

  test('loads persisted histories and derives splits, laps, and statistics',
      () async {
    await viewModel.load();

    expect(viewModel.loadCommand.isSuccess, isTrue);
    expect(viewModel.histories, hasLength(6));
    expect(viewModel.events.whereType<TrainingStarted>(), hasLength(1));
    expect(viewModel.splits, hasLength(5));
    expect(viewModel.laps, hasLength(1));
    expect(viewModel.laps.single.duration, const Duration(seconds: 60));
    expect(viewModel.statistics.persistedEntryCount, 6);
    expect(viewModel.statistics.splitCount, 5);
    expect(viewModel.statistics.lapCount, 1);
    expect(viewModel.statistics.measuredDuration, const Duration(seconds: 60));
    expect(viewModel.statistics.measuredDistance, 1000);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.lastError, isNull);
    expect(() => viewModel.events.add(const TrainingStarted()),
        throwsUnsupportedError);
  });

  test('updates only comments and immediately refreshes derived events',
      () async {
    await viewModel.load();

    await viewModel.updateComments(
      historyEntryId: 6,
      comments: 'updated lap',
    );

    expect(viewModel.updateCommentsCommand.isSuccess, isTrue);
    expect(viewModel.histories.last.comments, 'updated lap');
    expect(viewModel.splits.last.comments, 'updated lap');
    expect(viewModel.laps.single.comments, 'updated lap');
    expect(viewModel.statistics.measuredDuration, const Duration(seconds: 60));
  });

  test('deletes an intermediate split, merges its duration, and rederives',
      () async {
    await viewModel.load();

    await viewModel.delete(2);

    expect(viewModel.deleteCommand.isSuccess, isTrue);
    expect(viewModel.histories.map((entry) => entry.id), [1, 3, 4, 5, 6]);
    expect(viewModel.histories[1].duration, const Duration(seconds: 21));
    expect(viewModel.splits, hasLength(4));
    expect(viewModel.laps, isEmpty);
    expect(viewModel.statistics.measuredDuration, const Duration(seconds: 60));
    expect(viewModel.statistics.measuredDistance, 800);
  });

  test('rejects deletion of the start marker and final measurement', () async {
    await viewModel.load();

    await viewModel.delete(1);
    expect(viewModel.deleteCommand.isFailure, isTrue);
    expect(viewModel.lastError?.code, AppErrorCode.invalidData);

    await viewModel.delete(6);
    expect(viewModel.deleteCommand.isFailure, isTrue);
    expect(viewModel.histories, hasLength(6));
  });

  test('failed mutations preserve presentation and expose the last error',
      () async {
    await viewModel.load();
    final events = viewModel.events;
    final statistics = viewModel.statistics;
    repository.failUpdate = true;

    await viewModel.updateComments(historyEntryId: 3, comments: 'ignored');

    expect(viewModel.updateCommentsCommand.isFailure, isTrue);
    expect(viewModel.lastError, writeFailure);
    expect(viewModel.events, same(events));
    expect(viewModel.statistics, same(statistics));

    viewModel.clearLastError();
    expect(viewModel.lastError, isNull);
  });

  test('failed reload preserves the latest valid cache and presentation',
      () async {
    await viewModel.load();
    final histories = viewModel.histories;
    final events = viewModel.events;
    repository.failLoad = true;

    await viewModel.load();

    expect(viewModel.loadCommand.isFailure, isTrue);
    expect(viewModel.lastError, readFailure);
    expect(viewModel.histories, histories);
    expect(viewModel.events, same(events));
  });

  test('requires a persisted training before loading histories', () async {
    final transient = Training.create(
      userId: 1,
      date: DateTime(2026, 8, 20),
    ).value!;
    final transientViewModel = HistoryViewModel(
      training: transient,
      historyRepository: repository,
    );
    addTearDown(transientViewModel.dispose);

    await transientViewModel.load();

    expect(transientViewModel.loadCommand.isFailure, isTrue);
    expect(transientViewModel.lastError?.code, AppErrorCode.invalidData);
    expect(repository.loadCalls, 0);
  });
}
