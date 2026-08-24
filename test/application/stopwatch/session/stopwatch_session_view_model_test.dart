import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_bloc.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_state.dart';
import 'package:trainers_stopwatch/application/stopwatch/session/stopwatch_session_message.dart';
import 'package:trainers_stopwatch/application/stopwatch/session/stopwatch_session_state.dart';
import 'package:trainers_stopwatch/application/stopwatch/session/stopwatch_session_view_model.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/create_training_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';

const _writeFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'write failed',
);

class _TrainingRepositoryFake implements TrainingRepository {
  final List<String> operations;
  int nextId = 40;

  _TrainingRepositoryFake(this.operations);

  @override
  AsyncResult<Training> insert(Training training) async {
    operations.add('training');
    return Training.create(
      id: nextId++,
      userId: training.userId,
      date: training.date,
      comments: training.comments,
      splitDistance: training.splitDistance,
      lapDistance: training.lapDistance,
      maxLaps: training.maxLaps,
      speedUnit: training.speedUnit,
    );
  }

  @override
  AsyncResult<Unit> delete(Training training) async => const Success(unit);

  @override
  AsyncResult<List<Training>> loadForUser(int userId) async =>
      const Success([]);

  @override
  List<Training> trainingsForUser(int userId) => const [];

  @override
  AsyncResult<Unit> update(Training training) async => const Success(unit);
}

class _HistoryRepositoryFake implements HistoryRepository {
  final List<String> operations;
  final List<HistoryEntry> attemptedSnapshotWrites = [];
  bool failSnapshotWrite = false;
  int nextId = 80;

  _HistoryRepositoryFake(this.operations);

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) async {
    operations.add('initial history');
    return _persist(entry);
  }

  @override
  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry) async {
    operations.add('snapshot ${entry.snapshotRevision}');
    attemptedSnapshotWrites.add(entry);
    if (failSnapshotWrite) return const Failure(_writeFailure);
    return _persist(entry);
  }

  Result<HistoryEntry> _persist(HistoryEntry entry) => HistoryEntry.create(
        id: nextId++,
        trainingId: entry.trainingId,
        duration: entry.duration,
        comments: entry.comments,
        snapshotRevision: entry.snapshotRevision,
        snapshotType: entry.snapshotType,
      );

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

class _ControlledStopwatch implements Stopwatch {
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  void advance(Duration duration) {
    if (_isRunning) _elapsed += duration;
  }

  @override
  Duration get elapsed => _elapsed;
  @override
  int get elapsedMicroseconds => _elapsed.inMicroseconds;
  @override
  int get elapsedMilliseconds => _elapsed.inMilliseconds;
  @override
  int get elapsedTicks => _elapsed.inMicroseconds;
  @override
  int get frequency => Duration.microsecondsPerSecond;
  @override
  bool get isRunning => _isRunning;
  @override
  void reset() => _elapsed = Duration.zero;
  @override
  void start() => _isRunning = true;
  @override
  void stop() => _isRunning = false;
}

void main() {
  late List<String> operations;
  late _TrainingRepositoryFake trainingRepository;
  late _HistoryRepositoryFake historyRepository;
  late _ControlledStopwatch clock;
  late StopwatchSessionViewModel session;

  StopwatchSessionViewModel createSession({int? maxLaps}) {
    const user = User(id: 7, name: 'Ana', email: 'ana@example.com');
    final training = Training.create(
      userId: 7,
      date: DateTime.utc(2026, 8, 24),
      maxLaps: maxLaps,
    ).value!;
    clock = _ControlledStopwatch();
    final bloc = StopwatchBloc(
      createStopwatch: () => clock,
      now: () => DateTime.utc(2026, 8, 24, 12),
      tickInterval: const Duration(days: 1),
    );
    return StopwatchSessionViewModel(
      user: user,
      training: training,
      bloc: bloc,
      createTrainingUseCase: CreateTrainingUseCase(
        trainingRepository: trainingRepository,
        historyRepository: historyRepository,
      ),
      persistSnapshotUseCase: PersistStopwatchSnapshotUseCase(
        historyRepository: historyRepository,
      ),
      now: () => DateTime.utc(2026, 8, 24, 12),
    );
  }

  setUp(() {
    operations = [];
    trainingRepository = _TrainingRepositoryFake(operations);
    historyRepository = _HistoryRepositoryFake(operations);
    session = createSession();
  });

  tearDown(() => session.close());

  test('persists training before starting its exclusive bloc', () async {
    final result = await session.start();

    expect(result.isSuccess, isTrue);
    expect(operations.take(2), ['training', 'initial history']);
    expect(session.bloc.state.status, StopwatchStatus.running);
    expect(session.training.id, 40);
    expect(
      session.state.initializationStatus,
      StopwatchSessionInitializationStatus.ready,
    );
    expect(session.state.messages.single.type,
        StopwatchSessionMessageType.started);
  });

  test('coordinates pause, resume and finish through named methods', () async {
    await session.start();
    clock.advance(const Duration(seconds: 3));

    expect((await session.pause()).isSuccess, isTrue);
    expect(session.bloc.state.status, StopwatchStatus.paused);
    expect((await session.resume()).isSuccess, isTrue);
    expect(session.bloc.state.status, StopwatchStatus.running);
    expect((await session.pause()).isSuccess, isTrue);
    expect((await session.finish()).isSuccess, isTrue);

    expect(session.bloc.state.status, StopwatchStatus.finished);
    expect(session.isSynchronized, isTrue);
    expect(
      session.state.messages.last.type,
      StopwatchSessionMessageType.finished,
    );
  });

  test('keeps the exact pending write and publishes once after retry',
      () async {
    await session.start();
    clock.advance(const Duration(seconds: 4));
    historyRepository.failSnapshotWrite = true;

    final failed = await session.split();
    final pending = session.state.pendingWrite;

    expect(failed.isFailure, isTrue);
    expect(pending, isNotNull);
    expect(session.state.persistenceStatus,
        StopwatchSessionPersistenceStatus.failed);
    expect(session.state.messages, hasLength(1));

    historyRepository.failSnapshotWrite = false;
    final retried = await session.retryPendingWrite();

    expect(retried.isSuccess, isTrue);
    expect(session.state.pendingWrite, isNull);
    expect(session.state.messages, hasLength(2));
    expect(session.state.messages.last.type, StopwatchSessionMessageType.split);
    expect(historyRepository.attemptedSnapshotWrites, hasLength(2));
    expect(
      historyRepository.attemptedSnapshotWrites[0],
      historyRepository.attemptedSnapshotWrites[1],
    );
  });

  test('automatic lap limit persists its measurement only once', () async {
    await session.close();
    session = createSession(maxLaps: 1);
    await session.start();
    clock.advance(const Duration(seconds: 5));

    final result = await session.lap();

    expect(result.isSuccess, isTrue);
    expect(session.bloc.state.status, StopwatchStatus.finished);
    expect(historyRepository.attemptedSnapshotWrites, hasLength(1));
    expect(
      session.state.messages.map((message) => message.type),
      [
        StopwatchSessionMessageType.started,
        StopwatchSessionMessageType.split,
        StopwatchSessionMessageType.lap,
        StopwatchSessionMessageType.finished,
      ],
    );
  });

  test('close is idempotent and closes only the session bloc', () async {
    await session.start();

    await session.close();
    await session.close();

    expect(session.bloc.isClosed, isTrue);
    expect((await session.pause()).isFailure, isTrue);
  });
}
