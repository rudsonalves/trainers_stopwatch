import 'dart:async';

import 'package:flutter/foundation.dart';

import '/core/result/result.dart';
import '/domain/common/history/models/history_entry.dart';
import '/domain/common/stopwatch/models/stopwatch_snapshot.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/training/services/speed_calculator.dart';
import '/domain/common/training/values/distance.dart';
import '/domain/common/training/values/speed.dart';
import '/domain/common/user/models/user.dart';
import '/domain/usecases/trainings/create_training_use_case.dart';
import '/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';
import '../bloc/stopwatch_bloc.dart';
import '../bloc/stopwatch_event.dart';
import '../bloc/stopwatch_state.dart';
import 'stopwatch_session_id.dart';
import 'stopwatch_session_message.dart';
import 'stopwatch_session_state.dart';
import 'stopwatch_session_write.dart';

class StopwatchSessionViewModel extends ChangeNotifier {
  final StopwatchBloc bloc;
  final CreateTrainingUseCase _createTrainingUseCase;
  final PersistStopwatchSnapshotUseCase _persistSnapshotUseCase;
  final SpeedCalculator _speedCalculator;
  final DateTime Function() _now;
  int _colorValue;

  late StopwatchSessionState _state;
  Future<Result<Unit>>? _activeOperation;
  Future<void>? _closing;
  bool _closed = false;
  bool _notifierDisposed = false;

  StopwatchSessionViewModel({
    required User user,
    required Training training,
    required this.bloc,
    required CreateTrainingUseCase createTrainingUseCase,
    required PersistStopwatchSnapshotUseCase persistSnapshotUseCase,
    SpeedCalculator speedCalculator = const SpeedCalculator(),
    DateTime Function()? now,
    int colorValue = 0xff000000,
  })  : _createTrainingUseCase = createTrainingUseCase,
        _persistSnapshotUseCase = persistSnapshotUseCase,
        _speedCalculator = speedCalculator,
        _now = now ?? DateTime.now,
        _colorValue = colorValue {
    final id = StopwatchSessionId.fromUser(user);
    if (id.isFailure) throw id.error!;
    if (training.userId != id.value!.userId) {
      throw const AppError(
        code: AppErrorCode.invalidData,
        message: 'Session training must belong to its user.',
      );
    }
    _state = StopwatchSessionState(
      id: id.value!,
      user: user,
      training: training,
    );
  }

  StopwatchSessionState get state => _state;
  StopwatchSessionId get id => _state.id;
  User get user => _state.user;
  Training get training => _state.training!;
  bool get isOperationRunning => _activeOperation != null;
  int get colorValue => _colorValue;
  bool get hasPendingWrite => _state.pendingWrite != null;
  bool get isSynchronized =>
      !hasPendingWrite &&
      _state.persistenceStatus ==
          StopwatchSessionPersistenceStatus.synchronized;

  AsyncResult<Unit> start() => _execute(_start);

  AsyncResult<Unit> pause() => _execute(() async {
        if (bloc.state.status != StopwatchStatus.running) {
          return _invalidTransition('pause');
        }
        await _dispatchAndWait(
          const StopwatchEventPause(),
          (state) => state.status == StopwatchStatus.paused,
        );
        return const Success(unit);
      });

  AsyncResult<Unit> resume() => _execute(() async {
        if (bloc.state.status != StopwatchStatus.paused) {
          return _invalidTransition('resume');
        }
        await _dispatchAndWait(
          const StopwatchEventResume(),
          (state) => state.status == StopwatchStatus.running,
        );
        return const Success(unit);
      });

  AsyncResult<Unit> reset() => _execute(() async {
        if (hasPendingWrite) return _pendingWriteFailure();
        if (bloc.state.status != StopwatchStatus.paused &&
            bloc.state.status != StopwatchStatus.finished) {
          return _invalidTransition('reset');
        }
        await _dispatchAndWait(
          const StopwatchEventReset(),
          (state) => state.status == StopwatchStatus.idle,
        );
        _setState(
          _state.copyWith(
            training: _trainingDraft(training),
            initializationStatus:
                StopwatchSessionInitializationStatus.uninitialized,
            persistenceStatus: StopwatchSessionPersistenceStatus.synchronized,
            error: null,
          ),
        );
        return const Success(unit);
      });

  AsyncResult<Unit> split() => _execute(
        () => _recordSnapshot(
          operation: 'split',
          event: const StopwatchEventSplit(),
        ),
      );

  AsyncResult<Unit> lap() => _execute(
        () => _recordSnapshot(
          operation: 'lap',
          event: const StopwatchEventLap(),
        ),
      );

  AsyncResult<Unit> finish() => _execute(
        () => _recordSnapshot(
          operation: 'finish',
          event: const StopwatchEventStop(),
          allowsPaused: true,
        ),
      );

  AsyncResult<Unit> retryPendingWrite() => _execute(() async {
        final pending = _state.pendingWrite;
        if (pending == null) return const Success(unit);
        return _persist(pending);
      });

  Result<Unit> updateTraining(Training updated, {int? colorValue}) {
    if (_closed || isOperationRunning) return _busyFailure();
    if (updated.userId != id.userId || updated.id != null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Session configuration requires an unpersisted training.',
        ),
      );
    }
    if (bloc.state.status != StopwatchStatus.idle &&
        bloc.state.status != StopwatchStatus.finished) {
      return _invalidTransition('update training');
    }
    if (colorValue != null) _colorValue = colorValue;
    _setState(_state.copyWith(training: updated, error: null));
    return const Success(unit);
  }

  AsyncResult<Unit> _start() async {
    if (hasPendingWrite) return _pendingWriteFailure();
    if (bloc.state.status != StopwatchStatus.idle &&
        bloc.state.status != StopwatchStatus.finished) {
      return _invalidTransition('start');
    }

    final draft = _trainingDraft(training);
    _setState(
      _state.copyWith(
        training: draft,
        initializationStatus: StopwatchSessionInitializationStatus.loading,
        persistenceStatus: StopwatchSessionPersistenceStatus.writing,
        error: null,
      ),
    );
    final initialization = await _createTrainingUseCase.execute(
      training: draft,
      initialComments: 'Training started',
    );
    if (initialization.isFailure) {
      _setState(
        _state.copyWith(
          initializationStatus:
              StopwatchSessionInitializationStatus.uninitialized,
          persistenceStatus: StopwatchSessionPersistenceStatus.failed,
          error: initialization.error,
        ),
      );
      return Failure(initialization.error!);
    }

    final persisted = initialization.value!.training;
    final splitsPerLap =
        (persisted.lapDistance.value / persisted.splitDistance.value).round();
    if (splitsPerLap <= 0) {
      const error = AppError(
        code: AppErrorCode.invalidData,
        message: 'Training must contain at least one split per lap.',
      );
      _setState(
        _state.copyWith(
          persistenceStatus: StopwatchSessionPersistenceStatus.failed,
          error: error,
        ),
      );
      return const Failure(error);
    }

    if (bloc.state.maxLaps != persisted.maxLaps ||
        bloc.state.splitsPerLap != splitsPerLap) {
      await _dispatchAndWait(
        StopwatchEventConfigure(
          maxLaps: persisted.maxLaps,
          splitsPerLap: splitsPerLap,
        ),
        (state) =>
            state.maxLaps == persisted.maxLaps &&
            state.splitsPerLap == splitsPerLap,
      );
    }
    final running = await _dispatchAndWait(
      const StopwatchEventRun(),
      (state) => state.status == StopwatchStatus.running,
    );
    _setState(
      _state.copyWith(
        training: persisted,
        initializationStatus: StopwatchSessionInitializationStatus.ready,
        persistenceStatus: StopwatchSessionPersistenceStatus.synchronized,
        error: null,
        messages: [
          ..._state.messages,
          _message(
            type: StopwatchSessionMessageType.started,
            revision: 0,
            occurredAt: running.startedAt ?? _now(),
            comments: 'Training started',
          ),
        ],
      ),
    );
    return const Success(unit);
  }

  AsyncResult<Unit> _recordSnapshot({
    required String operation,
    required StopwatchEvent event,
    bool allowsPaused = false,
  }) async {
    if (hasPendingWrite) return _pendingWriteFailure();
    final status = bloc.state.status;
    if (status != StopwatchStatus.running &&
        !(allowsPaused && status == StopwatchStatus.paused)) {
      return _invalidTransition(operation);
    }

    final previousRevision = bloc.state.snapshotRevision;
    final produced = await _dispatchAndWait(
      event,
      (state) => state.snapshotRevision > previousRevision,
    );
    final write = _writeFrom(produced);
    if (write.isFailure) return Failure(write.error!);
    final persisted = await _persist(write.value!);
    if (persisted.isFailure) return persisted;

    final latest = bloc.state;
    if (operation == 'lap' &&
        latest.status == StopwatchStatus.finished &&
        latest.snapshotRevision > produced.snapshotRevision) {
      _setState(
        _state.copyWith(
          messages: [
            ..._state.messages,
            _message(
              type: StopwatchSessionMessageType.finished,
              revision: latest.snapshotRevision,
              occurredAt: latest.finishedAt ?? _now(),
              duration: latest.elapsed,
              comments: 'Training finished',
            ),
          ],
        ),
      );
    }
    return const Success(unit);
  }

  Result<StopwatchSessionWrite> _writeFrom(StopwatchState stopwatchState) {
    final trainingId = training.id;
    final snapshot = stopwatchState.snapshot;
    if (trainingId == null || snapshot == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A persisted training and snapshot are required.',
        ),
      );
    }
    return StopwatchSessionWrite.create(
      trainingId: trainingId,
      snapshotRevision: stopwatchState.snapshotRevision,
      snapshot: snapshot,
    );
  }

  AsyncResult<Unit> _persist(StopwatchSessionWrite write) async {
    _setState(
      _state.copyWith(
        pendingWrite: write,
        persistenceStatus: StopwatchSessionPersistenceStatus.writing,
        error: null,
      ),
    );
    final result = await _persistSnapshotUseCase.execute(
      trainingId: write.trainingId,
      snapshotRevision: write.snapshotRevision,
      snapshot: write.snapshot,
      comments: write.comments,
    );
    if (result.isFailure) {
      _setState(
        _state.copyWith(
          persistenceStatus: StopwatchSessionPersistenceStatus.failed,
          error: result.error,
        ),
      );
      return Failure(result.error!);
    }

    _setState(
      _state.copyWith(
        pendingWrite: null,
        persistenceStatus: StopwatchSessionPersistenceStatus.synchronized,
        error: null,
        messages: [
          ..._state.messages,
          ..._messagesFor(write, result.value!),
        ],
      ),
    );
    return const Success(unit);
  }

  List<StopwatchSessionMessage> _messagesFor(
    StopwatchSessionWrite write,
    HistoryEntry persisted,
  ) {
    final occurredAt = _now();
    return switch (write.snapshot) {
      SplitSnapshot(:final splitDuration, :final splitCount) => [
          _message(
            type: StopwatchSessionMessageType.split,
            revision: write.snapshotRevision,
            occurredAt: occurredAt,
            label: 'Split[$splitCount]',
            duration: splitDuration,
            speed: _speed(splitDuration, training.splitDistance),
            comments: persisted.comments ?? '',
          ),
        ],
      LapSnapshot(
        :final splitDuration,
        :final lapDuration,
        :final splitCount,
        :final lapCount,
      ) =>
        [
          _message(
            type: StopwatchSessionMessageType.split,
            revision: write.snapshotRevision,
            occurredAt: occurredAt,
            label: 'Split[$splitCount]',
            duration: splitDuration,
            speed: _speed(splitDuration, training.splitDistance),
          ),
          _message(
            type: StopwatchSessionMessageType.lap,
            revision: write.snapshotRevision,
            occurredAt: occurredAt,
            label: 'Lap[$lapCount]',
            duration: lapDuration,
            speed: _speed(lapDuration, training.lapDistance),
          ),
        ],
      FinishSnapshot(
        :final finalSplitDuration,
        :final finalLapDuration,
        :final splitCount,
        :final lapCount,
        :final elapsed,
      ) =>
        [
          _message(
            type: StopwatchSessionMessageType.split,
            revision: write.snapshotRevision,
            occurredAt: occurredAt,
            label: 'Split[$splitCount]',
            duration: finalSplitDuration,
            speed: _speed(finalSplitDuration, training.splitDistance),
          ),
          _message(
            type: StopwatchSessionMessageType.lap,
            revision: write.snapshotRevision,
            occurredAt: occurredAt,
            label: 'Lap[$lapCount]',
            duration: finalLapDuration,
            speed: _speed(finalLapDuration, training.lapDistance),
          ),
          _message(
            type: StopwatchSessionMessageType.finished,
            revision: write.snapshotRevision,
            occurredAt: occurredAt,
            duration: elapsed,
            comments: 'Training finished',
          ),
        ],
    };
  }

  Speed? _speed(Duration duration, Distance distance) {
    if (duration == Duration.zero) return null;
    return _speedCalculator
        .calculate(
          distance: distance,
          duration: duration,
          outputUnit: training.speedUnit,
        )
        .value;
  }

  StopwatchSessionMessage _message({
    required StopwatchSessionMessageType type,
    required int revision,
    required DateTime occurredAt,
    String label = '',
    Duration duration = Duration.zero,
    Speed? speed,
    String comments = '',
  }) =>
      StopwatchSessionMessage(
        id: StopwatchSessionMessageId(
          sessionId: id,
          snapshotRevision: revision,
          type: type,
        ),
        occurredAt: occurredAt,
        userName: user.name,
        label: label,
        duration: duration,
        speed: speed,
        comments: comments,
        colorValue: colorValue,
      );

  Training _trainingDraft(Training source) => Training.create(
        userId: source.userId,
        date: _now(),
        comments: source.comments,
        splitDistance: source.splitDistance,
        lapDistance: source.lapDistance,
        maxLaps: source.maxLaps,
        speedUnit: source.speedUnit,
      ).value!;

  Future<StopwatchState> _dispatchAndWait(
    StopwatchEvent event,
    bool Function(StopwatchState) matches,
  ) {
    final next = bloc.stream.firstWhere(matches);
    bloc.add(event);
    return next;
  }

  AsyncResult<Unit> _execute(AsyncResult<Unit> Function() action) {
    if (_closed) return Future.value(_closedFailure());
    if (_activeOperation != null) return Future.value(_busyFailure());
    final operation = action();
    _activeOperation = operation;
    notifyListeners();
    return operation.whenComplete(() {
      _activeOperation = null;
      if (!_closed) notifyListeners();
    });
  }

  Failure<Unit> _invalidTransition(String operation) => Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Cannot $operation in the current stopwatch state.',
          details: bloc.state.status,
        ),
      );

  Failure<Unit> _pendingWriteFailure() => const Failure(
        AppError(
          code: AppErrorCode.storageWriteFailed,
          message: 'Retry the pending write before another action.',
        ),
      );

  Failure<Unit> _busyFailure() => const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Another session operation is already running.',
        ),
      );

  Failure<Unit> _closedFailure() => const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'The stopwatch session is closed.',
        ),
      );

  void _setState(StopwatchSessionState state) {
    _state = state;
    if (!_closed) notifyListeners();
  }

  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    _closed = true;
    await _activeOperation;
    await bloc.close();
    if (!_notifierDisposed) {
      _notifierDisposed = true;
      super.dispose();
    }
  }

  @override
  void dispose() {
    if (_notifierDisposed) return;
    _closed = true;
    unawaited(close());
    _notifierDisposed = true;
    super.dispose();
  }
}
