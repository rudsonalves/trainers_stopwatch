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
import 'package:trainers_stopwatch/ui/pages/stopwatch/stopwatch_page_view_model.dart';

const _writeFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'write failed',
);

class _TrainingRepositoryFake implements TrainingRepository {
  final List<String> operations;
  int nextId = 40;
  bool failInsert = false;

  _TrainingRepositoryFake(this.operations);

  @override
  AsyncResult<Training> insert(Training training) async {
    operations.add('training');
    if (failInsert) return const Failure(_writeFailure);
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

  test('does not start the bloc when training creation fails', () async {
    trainingRepository.failInsert = true;

    final result = await session.start();

    expect(result.isFailure, isTrue);
    expect(session.bloc.state.status, StopwatchStatus.idle);
    expect(session.training.id, isNull);
    expect(session.state.messages, isEmpty);
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

  group('page coordination', () {
    late StopwatchPageViewModel page;
    late Map<int, _ControlledStopwatch> clocks;

    StopwatchSessionViewModel sessionFor(User user) {
      final stopwatch = _ControlledStopwatch();
      clocks[user.id!] = stopwatch;
      return StopwatchSessionViewModel(
        user: user,
        training: Training.create(
          userId: user.id!,
          date: DateTime.utc(2026, 8, 24),
        ).value!,
        bloc: StopwatchBloc(
          createStopwatch: () => stopwatch,
          now: () => DateTime.utc(2026, 8, 24, 12),
          tickInterval: const Duration(days: 1),
        ),
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
      clocks = {};
      page = StopwatchPageViewModel(sessionFactory: sessionFor);
    });

    tearDown(() => page.close());

    test('creates one stable session per athlete and rejects duplicates', () {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');

      expect(page.addUsers([ana, ana]).isSuccess, isTrue);
      final first = page.sessions.single;
      expect(page.addUsers([ana]).isSuccess, isTrue);

      expect(page.sessions, hasLength(1));
      expect(page.sessions.single, same(first));
      expect(page.activeUserIds, {7});
    });

    test('one athlete operation does not alter another session', () async {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      const bia = User(id: 8, name: 'Bia', email: 'bia@example.com');
      page.addUsers([ana, bia]);
      final anaSession = page.sessions[0];
      final biaSession = page.sessions[1];

      await anaSession.start();
      clocks[7]!.advance(const Duration(seconds: 3));
      await anaSession.split();

      expect(anaSession.bloc.state.status, StopwatchStatus.running);
      expect(anaSession.state.messages, hasLength(2));
      expect(biaSession.bloc.state.status, StopwatchStatus.idle);
      expect(biaSession.state.messages, isEmpty);
      expect(biaSession.training.id, isNull);
    });

    test('cancelled active removal preserves the measurement', () async {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      page.addUsers([ana]);
      final active = page.sessions.single;
      await active.start();

      final result = await page.removeSession(active.id);

      expect(result.isFailure, isTrue);
      expect(page.sessions.single, same(active));
      expect(active.bloc.state.status, StopwatchStatus.running);
    });

    test('removes idle and synchronized finished sessions directly', () async {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      const bia = User(id: 8, name: 'Bia', email: 'bia@example.com');
      page.addUsers([ana, bia]);
      final idle = page.sessions[0];
      final finished = page.sessions[1];
      await finished.start();
      await finished.finish();

      expect((await page.removeSession(idle.id)).isSuccess, isTrue);
      expect((await page.removeSession(finished.id)).isSuccess, isTrue);
      expect(page.sessions, isEmpty);
    });

    test('confirmed active removal finishes and closes only its session',
        () async {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      const bia = User(id: 8, name: 'Bia', email: 'bia@example.com');
      page.addUsers([ana, bia]);
      final removed = page.sessions[0];
      final retained = page.sessions[1];
      await removed.start();

      final result = await page.removeSession(removed.id, confirmed: true);

      expect(result.isSuccess, isTrue);
      expect(removed.bloc.isClosed, isTrue);
      expect(retained.bloc.isClosed, isFalse);
      expect(page.sessions, [same(retained)]);
    });

    test('confirmed paused removal persists and closes the session', () async {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      page.addUsers([ana]);
      final paused = page.sessions.single;
      await paused.start();
      clocks[7]!.advance(const Duration(seconds: 2));
      await paused.pause();

      final result = await page.removeSession(paused.id, confirmed: true);

      expect(result.isSuccess, isTrue);
      expect(paused.bloc.isClosed, isTrue);
      expect(historyRepository.attemptedSnapshotWrites, hasLength(1));
      expect(page.sessions, isEmpty);
    });

    test('failed final persistence retains session and retry enables removal',
        () async {
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      page.addUsers([ana]);
      final active = page.sessions.single;
      await active.start();
      historyRepository.failSnapshotWrite = true;

      final failed = await page.removeSession(active.id, confirmed: true);

      expect(failed.isFailure, isTrue);
      expect(page.sessions.single, same(active));
      expect(active.hasPendingWrite, isTrue);
      expect(active.bloc.state.status, StopwatchStatus.finished);

      historyRepository.failSnapshotWrite = false;
      expect((await active.retryPendingWrite()).isSuccess, isTrue);
      expect((await page.removeSession(active.id)).isSuccess, isTrue);
      expect(page.sessions, isEmpty);
    });

    test('projects messages in order and removes only the athlete messages',
        () async {
      const bia = User(id: 8, name: 'Bia', email: 'bia@example.com');
      const ana = User(id: 7, name: 'Ana', email: 'ana@example.com');
      page.addUsers([bia, ana]);
      final biaSession = page.sessions[0];
      final anaSession = page.sessions[1];
      await biaSession.start();
      await anaSession.start();

      expect(
          page.messages.map((message) => message.id.sessionId.userId), [7, 8]);

      await page.removeSession(anaSession.id, confirmed: true);

      expect(
        page.messages.map((message) => message.id.sessionId.userId).toSet(),
        {8},
      );
      expect(page.sessions.single, same(biaSession));
    });
  });
}
