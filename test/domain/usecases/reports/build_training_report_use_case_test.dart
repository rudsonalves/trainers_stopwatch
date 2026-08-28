import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_build_outcome.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/build_training_report_use_case.dart';

void main() {
  late _FakeHistoryRepository repository;
  late BuildTrainingReportUseCase useCase;

  const user = User(
    id: 1,
    name: 'Ana',
    email: 'ana@example.com',
  );

  setUp(() {
    repository = _FakeHistoryRepository();
    useCase = BuildTrainingReportUseCase(
      historyRepository: repository,
    );
  });

  test('loads histories and preserves the received training order', () async {
    repository.historiesByTraining.addAll({
      10: _histories(trainingId: 10),
      20: _histories(trainingId: 20),
    });

    final result = await useCase.execute(
      user: user,
      trainings: [
        _training(id: 20, userId: 1),
        _training(id: 10, userId: 1),
      ],
    );

    expect(result.isSuccess, isTrue);
    expect(repository.loadedTrainingIds, [20, 10]);
    expect(
      result.value!.sections.map((section) => section.training.id),
      [20, 10],
    );
  });

  test('returns an empty report without accessing the repository', () async {
    final result = await useCase.execute(
      user: user,
      trainings: const [],
    );

    expect(result.isSuccess, isTrue);
    expect(result.value!.user, user);
    expect(result.value!.sections, isEmpty);
    expect(repository.loadedTrainingIds, isEmpty);
  });

  test('rejects a user without persistence identity', () async {
    const transientUser = User(
      name: 'Ana',
      email: 'ana@example.com',
    );

    final result = await useCase.execute(
      user: transientUser,
      trainings: [_training(id: 10, userId: 1)],
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(repository.loadedTrainingIds, isEmpty);
  });

  test('rejects a training without persistence identity', () async {
    final transientTraining = Training.create(
      userId: 1,
      date: DateTime(2026, 8, 25),
    ).value!;

    final result = await useCase.execute(
      user: user,
      trainings: [transientTraining],
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(repository.loadedTrainingIds, isEmpty);
  });

  test('rejects a training belonging to another user', () async {
    final result = await useCase.execute(
      user: user,
      trainings: [_training(id: 10, userId: 2)],
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(repository.loadedTrainingIds, isEmpty);
  });

  test('stops loading after the first repository failure', () async {
    repository.historiesByTraining.addAll({
      10: _histories(trainingId: 10),
      30: _histories(trainingId: 30),
    });
    repository.failuresByTraining[20] = const AppError(
      code: AppErrorCode.storageReadFailed,
      message: 'History loading failed.',
    );

    final result = await useCase.execute(
      user: user,
      trainings: [
        _training(id: 10, userId: 1),
        _training(id: 20, userId: 1),
        _training(id: 30, userId: 1),
      ],
    );

    expect(result.isFailure, isTrue);
    expect(result.error, repository.failuresByTraining[20]);
    expect(repository.loadedTrainingIds, [10, 20]);
    expect(result.value, isNull);
  });

  test('returns builder failure without exposing partial content', () async {
    repository.historiesByTraining.addAll({
      10: _histories(trainingId: 10),
      20: const [],
    });

    final result = await useCase.execute(
      user: user,
      trainings: [
        _training(id: 10, userId: 1),
        _training(id: 20, userId: 1),
      ],
    );

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.invalidData);
    expect(repository.loadedTrainingIds, [10, 20]);
    expect(result.value, isNull);
  });

  group('buildOutcome', () {
    test('preserves valid trainings and accumulates issues in order', () async {
      repository.historiesByTraining.addAll({
        10: _histories(trainingId: 10),
        20: [
          _history(
            id: 1,
            trainingId: 20,
            duration: Duration.zero,
          ),
        ],
        30: _histories(trainingId: 30),
      });
      repository.failuresByTraining[40] = const AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'History loading failed.',
      );

      final result = await useCase.buildOutcome(
        user: user,
        trainings: [
          _training(id: 10, userId: 1),
          _training(id: 20, userId: 1),
          _training(id: 30, userId: 1),
          _training(id: 40, userId: 1),
        ],
      );

      expect(result.isSuccess, isTrue);

      final outcome = result.value!;

      expect(outcome.status, TrainingReportBuildStatus.partial);
      expect(
        outcome.content.sections.map((section) => section.training.id),
        [10, 30],
      );
      expect(
        outcome.issues.map((issue) => issue.training.id),
        [20, 40],
      );
      expect(
        outcome.issues.map((issue) => issue.error.code),
        [
          AppErrorCode.zeroElapsedTime,
          AppErrorCode.storageReadFailed,
        ],
      );
      expect(repository.loadedTrainingIds, [10, 20, 30, 40]);
    });

    test('returns rejected when every training has an issue', () async {
      repository.historiesByTraining[10] = [
        _history(
          id: 1,
          trainingId: 10,
          duration: Duration.zero,
        ),
      ];
      repository.failuresByTraining[20] = const AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'History loading failed.',
      );

      final result = await useCase.buildOutcome(
        user: user,
        trainings: [
          _training(id: 10, userId: 1),
          _training(id: 20, userId: 1),
        ],
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.status, TrainingReportBuildStatus.rejected);
      expect(result.value!.content.sections, isEmpty);
      expect(result.value!.issues, hasLength(2));
      expect(repository.loadedTrainingIds, [10, 20]);
    });

    test('returns complete when every training is valid', () async {
      repository.historiesByTraining.addAll({
        10: _histories(trainingId: 10),
        20: _histories(trainingId: 20),
      });

      final result = await useCase.buildOutcome(
        user: user,
        trainings: [
          _training(id: 20, userId: 1),
          _training(id: 10, userId: 1),
        ],
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.status, TrainingReportBuildStatus.complete);
      expect(
        result.value!.content.sections.map(
          (section) => section.training.id,
        ),
        [20, 10],
      );
      expect(result.value!.issues, isEmpty);
    });

    test('keeps an invalid user as a global failure', () async {
      const transientUser = User(
        name: 'Ana',
        email: 'ana@example.com',
      );

      final result = await useCase.buildOutcome(
        user: transientUser,
        trainings: [_training(id: 10, userId: 1)],
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
      expect(repository.loadedTrainingIds, isEmpty);
    });

    test('continues after an inconsistent training history', () async {
      repository.historiesByTraining.addAll({
        10: _histories(trainingId: 10),
        20: [
          _history(
            id: 1,
            trainingId: 20,
            duration: Duration.zero,
          ),
          _history(
            id: 2,
            trainingId: 20,
            duration: Duration.zero,
          ),
        ],
        30: _histories(trainingId: 30),
      });

      final result = await useCase.buildOutcome(
        user: user,
        trainings: [
          _training(id: 10, userId: 1),
          _training(id: 20, userId: 1),
          _training(id: 30, userId: 1),
        ],
      );

      expect(result.isSuccess, isTrue);

      final outcome = result.value!;

      expect(outcome.status, TrainingReportBuildStatus.partial);
      expect(
        outcome.content.sections.map((section) => section.training.id),
        [10, 30],
      );
      expect(
        outcome.issues.map((issue) => issue.training.id),
        [20],
      );
      expect(
        outcome.issues.single.error.code,
        AppErrorCode.invalidData,
      );
      expect(repository.loadedTrainingIds, [10, 20, 30]);
    });
  });

  test('accumulates training identity issues without loading their histories',
      () async {
    final transientTraining = Training.create(
      userId: 1,
      date: DateTime(2026, 8, 25),
    ).value!;

    repository.historiesByTraining[30] = _histories(trainingId: 30);

    final result = await useCase.buildOutcome(
      user: user,
      trainings: [
        transientTraining,
        _training(id: 20, userId: 2),
        _training(id: 30, userId: 1),
      ],
    );

    expect(result.isSuccess, isTrue);

    final outcome = result.value!;

    expect(outcome.status, TrainingReportBuildStatus.partial);
    expect(
      outcome.content.sections.map((section) => section.training.id),
      [30],
    );
    expect(outcome.issues, hasLength(2));
    expect(outcome.issues[0].training, transientTraining);
    expect(outcome.issues[0].error.code, AppErrorCode.invalidData);
    expect(outcome.issues[1].training.id, 20);
    expect(outcome.issues[1].error.code, AppErrorCode.invalidData);
    expect(repository.loadedTrainingIds, [30]);
  });
}

Training _training({
  required int id,
  required int userId,
}) =>
    Training.create(
      id: id,
      userId: userId,
      date: DateTime(2026, 8, 25),
    ).value!;

List<HistoryEntry> _histories({
  required int trainingId,
}) =>
    [
      _history(
        id: 1,
        trainingId: trainingId,
        duration: Duration.zero,
      ),
      _history(
        id: 2,
        trainingId: trainingId,
        duration: const Duration(seconds: 20),
      ),
    ];

HistoryEntry _history({
  required int id,
  required int trainingId,
  required Duration duration,
}) =>
    HistoryEntry.create(
      id: id,
      trainingId: trainingId,
      duration: duration,
    ).value!;

final class _FakeHistoryRepository implements HistoryRepository {
  final Map<int, List<HistoryEntry>> historiesByTraining = {};
  final Map<int, AppError> failuresByTraining = {};
  final List<int> loadedTrainingIds = [];

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) =>
      List.unmodifiable(historiesByTraining[trainingId] ?? const []);

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async {
    loadedTrainingIds.add(trainingId);

    final failure = failuresByTraining[trainingId];
    if (failure != null) return Failure(failure);

    return Success(historiesForTraining(trainingId));
  }

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) =>
      throw UnimplementedError();

  @override
  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry) =>
      throw UnimplementedError();

  @override
  AsyncResult<Unit> update(HistoryEntry entry) => throw UnimplementedError();

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) =>
      throw UnimplementedError();
}
