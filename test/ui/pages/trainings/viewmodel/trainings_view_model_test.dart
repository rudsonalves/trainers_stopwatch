import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/trainings_view_model.dart';

const readFailure = AppError(
  code: AppErrorCode.storageReadFailed,
  message: 'read failed',
);
const writeFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'write failed',
);

final class _UserRepositoryFake implements UserRepository {
  List<User> stored = const [];
  List<User> _cache = const [];
  bool failLoad = false;

  @override
  List<User> get users => _cache;

  @override
  AsyncResult<List<User>> loadAll() async {
    if (failLoad) return const Failure(readFailure);
    _cache = List.unmodifiable(stored);
    return Success(_cache);
  }

  @override
  AsyncResult<User> insert(User user) async => Success(user);

  @override
  AsyncResult<Unit> update(User user) async => const Success(unit);

  @override
  AsyncResult<Unit> delete(int id) async => const Success(unit);

  @override
  AsyncResult<List<String>> readPhotoReferences() async => const Success([]);
}

final class _TrainingRepositoryFake implements TrainingRepository {
  final Map<int, List<Training>> stored = {};
  final Map<int, List<Training>> _cache = {};
  bool failLoad = false;
  int? failDeleteId;
  bool failUpdate = false;
  int loadCalls = 0;

  @override
  List<Training> trainingsForUser(int userId) => _cache[userId] ?? const [];

  @override
  AsyncResult<List<Training>> loadForUser(int userId) async {
    loadCalls++;
    if (failLoad) return const Failure(readFailure);
    final snapshot = List<Training>.unmodifiable(stored[userId] ?? const []);
    _cache[userId] = snapshot;
    return Success(snapshot);
  }

  @override
  AsyncResult<Unit> update(Training training) async {
    if (failUpdate) return const Failure(writeFailure);
    final current = [...trainingsForUser(training.userId)];
    final index = current.indexWhere((item) => item.id == training.id);
    if (index >= 0) current[index] = training;
    _cache[training.userId] = List.unmodifiable(current);
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> delete(Training training) async {
    if (training.id == failDeleteId) return const Failure(writeFailure);
    _cache[training.userId] = List.unmodifiable(
      trainingsForUser(training.userId).where(
        (item) => item.id != training.id,
      ),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Training> insert(Training training) async => Success(training);
}

void main() {
  late _UserRepositoryFake userRepository;
  late _TrainingRepositoryFake trainingRepository;
  late TrainingsViewModel viewModel;

  const ana = User(id: 1, name: 'Ana', email: 'ana@example.com');
  const bia = User(id: 2, name: 'Bia', email: 'bia@example.com');

  Training training(int id, int userId, {String? comments}) => Training.create(
        id: id,
        userId: userId,
        date: DateTime(2026, 8, id),
        comments: comments,
      ).value!;

  setUp(() {
    userRepository = _UserRepositoryFake()..stored = const [ana, bia];
    trainingRepository = _TrainingRepositoryFake()
      ..stored[1] = [training(11, 1), training(12, 1)]
      ..stored[2] = [training(21, 2)];
    viewModel = TrainingsViewModel(
      userRepository: userRepository,
      trainingRepository: trainingRepository,
    );
    addTearDown(viewModel.dispose);
  });

  test('loads users and exposes command state', () async {
    await viewModel.loadUsers();

    expect(viewModel.loadUsersCommand.isSuccess, isTrue);
    expect(viewModel.users, [ana, bia]);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.lastError, isNull);
  });

  test('selects a user and loads only that user trainings', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    expect(viewModel.loadTrainingsCommand.isSuccess, isTrue);
    expect(viewModel.selectedUser, ana);
    expect(viewModel.trainings.map((item) => item.id), [11, 12]);
    expect(trainingRepository.loadCalls, 1);
  });

  test('rejects selection of an unavailable user', () async {
    await viewModel.loadUsers();

    await viewModel.selectUser(99);

    expect(viewModel.loadTrainingsCommand.isFailure, isTrue);
    expect(viewModel.lastError?.code, AppErrorCode.invalidData);
    expect(viewModel.selectedUser, isNull);
    expect(trainingRepository.loadCalls, 0);
  });

  test('keeps selection immutable and ignores unavailable trainings', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    final first = viewModel.trainings.first;
    viewModel.setSelected(first, selected: true);
    viewModel.setSelected(training(99, 1), selected: true);

    expect(viewModel.selectedTrainingIds, {11});
    expect(viewModel.selectedTrainings, [first]);
    expect(() => viewModel.selectedTrainingIds.add(12), throwsUnsupportedError);
  });

  test('selects all, clears, and resets selection when user changes', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();

    expect(viewModel.areAllTrainingsSelected, isTrue);
    expect(viewModel.selectedTrainingIds, {11, 12});

    await viewModel.selectUser(2);

    expect(viewModel.selectedTrainingIds, isEmpty);
    expect(viewModel.trainings.single.id, 21);
    viewModel.selectAll();
    viewModel.clearSelection();
    expect(viewModel.hasSelectedTrainings, isFalse);
  });

  test('reload reconciles selection with the latest repository cache',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    trainingRepository.stored[1] = [training(12, 1)];

    await viewModel.reloadTrainings();

    expect(viewModel.trainings.map((item) => item.id), [12]);
    expect(viewModel.selectedTrainingIds, {12});
  });

  test('update and delete reflect repository mutations and selection',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    final changed = training(11, 1, comments: 'changed');
    viewModel.setSelected(viewModel.trainings.first, selected: true);

    await viewModel.update(changed);
    await viewModel.delete(changed);

    expect(viewModel.updateCommand.isSuccess, isTrue);
    expect(viewModel.deleteCommand.isSuccess, isTrue);
    expect(viewModel.trainings.map((item) => item.id), [12]);
    expect(viewModel.selectedTrainingIds, isEmpty);
  });

  test('batch deletion reconciles partial success when a later delete fails',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    trainingRepository.failDeleteId = 12;

    await viewModel.deleteSelected();

    expect(viewModel.deleteSelectedCommand.isFailure, isTrue);
    expect(viewModel.lastError, writeFailure);
    expect(viewModel.trainings.map((item) => item.id), [12]);
    expect(viewModel.selectedTrainingIds, {12});
  });

  test('failed reload preserves cached trainings and reports AppError',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    final cached = viewModel.trainings;
    trainingRepository.failLoad = true;

    await viewModel.reloadTrainings();

    expect(viewModel.loadTrainingsCommand.isFailure, isTrue);
    expect(viewModel.lastError, readFailure);
    expect(viewModel.trainings, same(cached));

    viewModel.clearLastError();
    expect(viewModel.lastError, isNull);
  });

  test('removing the selected user on reload clears page selection', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    userRepository.stored = const [bia];

    await viewModel.loadUsers();

    expect(viewModel.selectedUser, isNull);
    expect(viewModel.trainings, isEmpty);
    expect(viewModel.selectedTrainingIds, isEmpty);
  });
}
