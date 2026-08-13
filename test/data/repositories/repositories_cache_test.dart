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
  bool failWrites = false;

  _TrainingServiceFake()
      : super(
          databaseService: UnusedDatabaseService(),
          mapper: const TrainingMapper(),
        );

  @override
  AsyncResult<List<Training>> readAllFromUser(int userId) async =>
      Success(stored);

  @override
  AsyncResult<Training> insert(Training training) async => Success(
        Training.create(id: 3, userId: training.userId, date: training.date)
            .value!,
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
  bool failDelete = false;

  _HistoryServiceFake()
      : super(
          databaseService: UnusedDatabaseService(),
          mapper: const HistoryMapper(),
        );

  @override
  AsyncResult<List<HistoryEntry>> readAllFromTraining(int trainingId) async =>
      Success(stored);

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async => Success(
        HistoryEntry.create(
          id: 4,
          trainingId: entry.trainingId,
          duration: entry.duration,
        ).value!,
      );

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) async =>
      failDelete ? failure : const Success(unit);
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
}
