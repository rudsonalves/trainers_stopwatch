import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository_impl.dart';
import 'package:trainers_stopwatch/data/repositories/settings/settings_repository_impl.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository_impl.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository_impl.dart';
import 'package:trainers_stopwatch/data/services/histories/history_mapper.dart';
import 'package:trainers_stopwatch/data/services/histories/history_service.dart';
import 'package:trainers_stopwatch/data/services/settings/settings_mapper.dart';
import 'package:trainers_stopwatch/data/services/settings/settings_service.dart';
import 'package:trainers_stopwatch/data/services/trainings/training_mapper.dart';
import 'package:trainers_stopwatch/data/services/trainings/training_service.dart';
import 'package:trainers_stopwatch/data/services/users/user_mapper.dart';
import 'package:trainers_stopwatch/data/services/users/user_service.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

import 'repository_test_support.dart';

const failure = Failure<Unit>(
  AppError(code: AppErrorCode.storageWriteFailed, message: 'failed'),
);

class _SettingsServiceFake extends SettingsService {
  SettingsLookup lookup = const SettingsMissing();
  bool failUpdate = false;

  _SettingsServiceFake()
      : super(
          databaseService: UnusedDatabaseService(),
          mapper: const SettingsMapper(),
        );

  @override
  AsyncResult<SettingsLookup> read() async => Success(lookup);

  @override
  AsyncResult<Settings> insert(Settings settings) async =>
      Settings.create(id: 1);

  @override
  AsyncResult<Unit> update(Settings settings) async =>
      failUpdate ? failure : const Success(unit);
}

class _UserServiceFake extends UserService {
  List<User> stored = const [];
  bool failWrites = false;

  _UserServiceFake()
      : super(
          databaseService: UnusedDatabaseService(),
          mapper: const UserMapper(),
        );

  @override
  AsyncResult<List<User>> readAll() async => Success(stored);

  @override
  AsyncResult<User> insert(User user) async => failWrites
      ? const Failure(
          AppError(code: AppErrorCode.storageWriteFailed, message: 'failed'),
        )
      : Success(
          User(id: 2, name: user.name, email: user.email),
        );

  @override
  AsyncResult<Unit> update(User user) async =>
      failWrites ? failure : const Success(unit);

  @override
  AsyncResult<Unit> delete(int id) async =>
      failWrites ? failure : const Success(unit);
}

class _TrainingServiceFake extends TrainingService {
  List<Training> stored = const [];
  bool failReads = false;
  bool failWrites = false;

  _TrainingServiceFake()
      : super(
          databaseService: UnusedDatabaseService(),
          mapper: const TrainingMapper(),
        );

  @override
  AsyncResult<List<Training>> readAllFromUser(int userId) async => failReads
      ? const Failure(
          AppError(
            code: AppErrorCode.storageReadFailed,
            message: 'failed',
          ),
        )
      : Success(stored);

  @override
  AsyncResult<Training> insert(Training training) async => failWrites
      ? const Failure(
          AppError(code: AppErrorCode.storageWriteFailed, message: 'failed'),
        )
      : Success(
          Training.create(
            id: 3,
            userId: training.userId,
            date: training.date,
            comments: training.comments,
          ).value!,
        );

  @override
  AsyncResult<Unit> update(Training training) async =>
      failWrites ? failure : const Success(unit);

  @override
  AsyncResult<Unit> delete(int id) async =>
      failWrites ? failure : const Success(unit);
}

class _HistoryServiceFake extends HistoryService {
  List<HistoryEntry> stored = const [];
  bool failReads = false;
  bool failWrites = false;

  _HistoryServiceFake()
      : super(
          databaseService: UnusedDatabaseService(),
          mapper: const HistoryMapper(),
        );

  @override
  AsyncResult<List<HistoryEntry>> readAllFromTraining(int trainingId) async =>
      failReads
          ? const Failure(
              AppError(
                code: AppErrorCode.storageReadFailed,
                message: 'failed',
              ),
            )
          : Success(stored);

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async => failWrites
      ? const Failure(
          AppError(code: AppErrorCode.storageWriteFailed, message: 'failed'),
        )
      : Success(
          HistoryEntry.create(
            id: 4,
            trainingId: entry.trainingId,
            duration: entry.duration,
            comments: entry.comments,
          ).value!,
        );

  @override
  AsyncResult<Unit> update(HistoryEntry entry) async =>
      failWrites ? failure : const Success(unit);

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async =>
      failWrites ? failure : const Success(unit);
}

void main() {
  test('settings creates defaults and preserves cache on update failure',
      () async {
    final service = _SettingsServiceFake();
    final repository = SettingsRepositoryImpl(service: service);
    final loaded = await repository.load();
    final cached = repository.current;
    service.failUpdate = true;

    final update = await repository.update(Settings.create(id: 2).value!);

    expect(loaded.value!.id, 1);
    expect(update.isFailure, isTrue);
    expect(repository.current, same(cached));
  });

  test('user cache changes only after successful persistence', () async {
    final service = _UserServiceFake()
      ..stored = const [User(id: 1, name: 'Ana', email: 'a@a.com')];
    final repository = UserRepositoryImpl(service: service);
    await repository.loadAll();
    service.failWrites = true;

    final result = await repository.insert(
      const User(name: 'Bia', email: 'b@b.com'),
    );

    expect(result.isFailure, isTrue);
    expect(repository.users.map((user) => user.name), ['Ana']);
    expect(() => repository.users.add(repository.users.first),
        throwsUnsupportedError);
  });

  test('training caches are isolated by user', () async {
    final service = _TrainingServiceFake();
    final repository = TrainingRepositoryImpl(service: service);
    service.stored = [
      Training.create(id: 1, userId: 1, date: DateTime(2026)).value!
    ];
    await repository.loadForUser(1);
    service.stored = [
      Training.create(id: 2, userId: 2, date: DateTime(2026)).value!
    ];
    await repository.loadForUser(2);

    expect(repository.trainingsForUser(1).single.id, 1);
    expect(repository.trainingsForUser(2).single.id, 2);
  });

  test('training cache is immutable and survives failed reads and writes',
      () async {
    final cachedTraining = Training.create(
      id: 1,
      userId: 1,
      date: DateTime(2026),
      comments: 'cached',
    ).value!;
    final service = _TrainingServiceFake()..stored = [cachedTraining];
    final repository = TrainingRepositoryImpl(service: service);
    await repository.loadForUser(1);
    final snapshot = repository.trainingsForUser(1);
    service
      ..failReads = true
      ..failWrites = true;

    final reload = await repository.loadForUser(1);
    final update = await repository.update(
      Training.create(
        id: 1,
        userId: 1,
        date: DateTime(2026),
        comments: 'changed',
      ).value!,
    );
    final deletion = await repository.delete(cachedTraining);

    expect(reload.isFailure, isTrue);
    expect(update.isFailure, isTrue);
    expect(deletion.isFailure, isTrue);
    expect(repository.trainingsForUser(1), same(snapshot));
    expect(repository.trainingsForUser(1).single.comments, 'cached');
    expect(
      () => repository.trainingsForUser(1).add(cachedTraining),
      throwsUnsupportedError,
    );
  });

  test('training cache reflects a persisted comment update', () async {
    final original = Training.create(
      id: 1,
      userId: 1,
      date: DateTime(2026),
      comments: 'before',
    ).value!;
    final changed = Training.create(
      id: 1,
      userId: 1,
      date: DateTime(2026),
      comments: 'after',
    ).value!;
    final service = _TrainingServiceFake()..stored = [original];
    final repository = TrainingRepositoryImpl(service: service);
    await repository.loadForUser(1);

    final result = await repository.update(changed);

    expect(result.isSuccess, isTrue);
    expect(repository.trainingsForUser(1).single, changed);
  });

  test('history cache mirrors duration merge after transaction success',
      () async {
    HistoryEntry entry(int id, int seconds) => HistoryEntry.create(
          id: id,
          trainingId: 9,
          duration: Duration(seconds: seconds),
        ).value!;
    final service = _HistoryServiceFake()
      ..stored = [entry(1, 0), entry(2, 1), entry(3, 2)];
    final repository = HistoryRepositoryImpl(service: service);
    await repository.loadForTraining(9);

    final result = await repository.deleteAndMergeNext(
      trainingId: 9,
      historyEntryId: 2,
    );

    expect(result.isSuccess, isTrue);
    expect(repository.historiesForTraining(9).map((item) => item.id), [1, 3]);
    expect(repository.historiesForTraining(9).last.duration,
        const Duration(seconds: 3));
  });

  test('history cache is immutable and survives failed reads and writes',
      () async {
    final cachedEntry = HistoryEntry.create(
      id: 1,
      trainingId: 9,
      duration: Duration.zero,
      comments: 'cached',
    ).value!;
    final service = _HistoryServiceFake()..stored = [cachedEntry];
    final repository = HistoryRepositoryImpl(service: service);
    await repository.loadForTraining(9);
    final snapshot = repository.historiesForTraining(9);
    service
      ..failReads = true
      ..failWrites = true;

    final reload = await repository.loadForTraining(9);
    final update = await repository.update(
      HistoryEntry.create(
        id: 1,
        trainingId: 9,
        duration: Duration.zero,
        comments: 'changed',
      ).value!,
    );

    expect(reload.isFailure, isTrue);
    expect(update.isFailure, isTrue);
    expect(repository.historiesForTraining(9), same(snapshot));
    expect(repository.historiesForTraining(9).single.comments, 'cached');
    expect(
      () => repository.historiesForTraining(9).add(cachedEntry),
      throwsUnsupportedError,
    );
  });

  test('history cache reflects a persisted comment update', () async {
    final original = HistoryEntry.create(
      id: 1,
      trainingId: 9,
      duration: Duration.zero,
      comments: 'before',
    ).value!;
    final changed = HistoryEntry.create(
      id: 1,
      trainingId: 9,
      duration: Duration.zero,
      comments: 'after',
    ).value!;
    final service = _HistoryServiceFake()..stored = [original];
    final repository = HistoryRepositoryImpl(service: service);
    await repository.loadForTraining(9);

    final result = await repository.update(changed);

    expect(result.isSuccess, isTrue);
    expect(repository.historiesForTraining(9).single, changed);
  });
}
