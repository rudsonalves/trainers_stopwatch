import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/create_training_use_case.dart';

const trainingFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'training failed',
);
const historyFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'history failed',
);
const compensationFailure = AppError(
  code: AppErrorCode.storageNotFound,
  message: 'compensation failed',
);

final class _TrainingRepositoryFake implements TrainingRepository {
  final List<String> operations;
  Result<Training>? insertionResult;
  Result<Unit> deletionResult = const Success(unit);
  Training? deletedTraining;

  _TrainingRepositoryFake(this.operations);

  @override
  AsyncResult<Training> insert(Training training) async {
    operations.add('insert training');
    return insertionResult ??
        Success(
          Training.create(
            id: 41,
            userId: training.userId,
            date: training.date,
            comments: training.comments,
            splitDistance: training.splitDistance,
            lapDistance: training.lapDistance,
            maxLaps: training.maxLaps,
            speedUnit: training.speedUnit,
          ).value!,
        );
  }

  @override
  AsyncResult<Unit> delete(Training training) async {
    operations.add('delete training');
    deletedTraining = training;
    return deletionResult;
  }

  @override
  List<Training> trainingsForUser(int userId) => const [];

  @override
  AsyncResult<List<Training>> loadForUser(int userId) async =>
      const Success([]);

  @override
  AsyncResult<Unit> update(Training training) async => const Success(unit);
}

final class _HistoryRepositoryFake implements HistoryRepository {
  final List<String> operations;
  Result<HistoryEntry>? insertionResult;
  HistoryEntry? insertedHistory;

  _HistoryRepositoryFake(this.operations);

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async {
    operations.add('insert history');
    insertedHistory = entry;
    return insertionResult ??
        HistoryEntry.create(
          id: 91,
          trainingId: entry.trainingId,
          duration: entry.duration,
          comments: entry.comments,
        );
  }

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async =>
      const Success(unit);

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) => const [];

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async =>
      const Success([]);

  @override
  AsyncResult<Unit> update(HistoryEntry entry) async => const Success(unit);
}

void main() {
  late List<String> operations;
  late _TrainingRepositoryFake trainingRepository;
  late _HistoryRepositoryFake historyRepository;
  late CreateTrainingUseCase useCase;

  Training newTraining() => Training.create(
        userId: 7,
        date: DateTime(2026, 8, 20),
        comments: 'intervals',
      ).value!;

  setUp(() {
    operations = [];
    trainingRepository = _TrainingRepositoryFake(operations);
    historyRepository = _HistoryRepositoryFake(operations);
    useCase = CreateTrainingUseCase(
      trainingRepository: trainingRepository,
      historyRepository: historyRepository,
    );
  });

  test('inserts training before its zero-duration initial history', () async {
    final result = await useCase.execute(
      training: newTraining(),
      initialComments: 'started',
    );

    expect(result.isSuccess, isTrue);
    expect(operations, ['insert training', 'insert history']);
    expect(result.value!.training.id, 41);
    expect(result.value!.initialHistory.id, 91);
    expect(result.value!.initialHistory.trainingId, 41);
    expect(result.value!.initialHistory.duration, Duration.zero);
    expect(result.value!.initialHistory.comments, 'started');
  });

  test('does not reach history when training insertion fails', () async {
    trainingRepository.insertionResult = const Failure(trainingFailure);

    final result = await useCase.execute(training: newTraining());

    expect(result.isFailure, isTrue);
    expect(result.error, same(trainingFailure));
    expect(operations, ['insert training']);
    expect(historyRepository.insertedHistory, isNull);
  });

  test('deletes training by cascade when initial history insertion fails',
      () async {
    historyRepository.insertionResult = const Failure(historyFailure);

    final result = await useCase.execute(training: newTraining());

    expect(result.isFailure, isTrue);
    expect(result.error, same(historyFailure));
    expect(
      operations,
      ['insert training', 'insert history', 'delete training'],
    );
    expect(trainingRepository.deletedTraining?.id, 41);
  });

  test('reports both errors when cascade compensation fails', () async {
    historyRepository.insertionResult = const Failure(historyFailure);
    trainingRepository.deletionResult = const Failure(compensationFailure);

    final result = await useCase.execute(training: newTraining());

    expect(result.isFailure, isTrue);
    expect(result.error!.code, compensationFailure.code);
    expect(result.error!.message, contains('could not be removed'));
    expect(result.error!.details.toString(), contains('history failed'));
    expect(result.error!.details.toString(), contains('compensation failed'));
    expect(result.error!.details.toString(), contains('41'));
  });

  test('rejects a successful insertion without persistence identity', () async {
    trainingRepository.insertionResult = Success(newTraining());

    final result = await useCase.execute(training: newTraining());

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(operations, ['insert training']);
  });
}
