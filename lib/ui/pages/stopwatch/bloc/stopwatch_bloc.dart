import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/common/stopwatch/models/stopwatch_snapshot.dart';
import 'stopwatch_event.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  final DateTime Function() _now;
  final Stopwatch _stopwatch;
  final Duration _tickInterval;

  StopwatchBloc({
    DateTime Function()? now,
    Stopwatch Function()? createStopwatch,
    Duration tickInterval = const Duration(milliseconds: 50),
    int? maxLaps,
    int splitsPerLap = 1,
  })  : assert(tickInterval > Duration.zero),
        assert(maxLaps == null || maxLaps > 0),
        assert(splitsPerLap > 0),
        _now = now ?? DateTime.now,
        _stopwatch = (createStopwatch ?? Stopwatch.new)(),
        _tickInterval = tickInterval,
        super(StopwatchState(maxLaps: maxLaps, splitsPerLap: splitsPerLap)) {
    on<StopwatchEventRun>(_startEvent);
    on<StopwatchEventPause>(_pauseEvent);
    on<StopwatchEventResume>(_resumeEvent);
    on<StopwatchEventReset>(_resetEvent);
    on<StopwatchEventSplit>(_splitEvent);
    on<StopwatchEventLap>(_lapEvent);
    on<StopwatchEventStop>(_stopEvent);
    on<StopwatchEventConfigure>(_configureEvent);
    on<_StopwatchEventTick>(_tickEvent);
  }

  Timer? _ticker;
  Duration _lastSplitElapsed = Duration.zero;
  Duration _lastLapElapsed = Duration.zero;

  void _startEvent(
    StopwatchEventRun event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.idle &&
        state.status != StopwatchStatus.finished) {
      return;
    }

    _cancelTicker();
    _stopwatch
      ..stop()
      ..reset()
      ..start();
    _lastSplitElapsed = Duration.zero;
    _lastLapElapsed = Duration.zero;

    emit(
      StopwatchState(
        status: StopwatchStatus.running,
        maxLaps: state.maxLaps,
        splitsPerLap: state.splitsPerLap,
        startedAt: _now(),
        snapshotRevision: state.snapshotRevision,
      ),
    );
    _startTicker();
  }

  void _pauseEvent(
    StopwatchEventPause event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.running) return;

    _stopwatch.stop();
    _cancelTicker();
    emit(
      state.copyWith(
        status: StopwatchStatus.paused,
        elapsed: _stopwatch.elapsed,
      ),
    );
  }

  void _resumeEvent(
    StopwatchEventResume event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.paused) return;

    _stopwatch.start();
    emit(
      state.copyWith(
        status: StopwatchStatus.running,
        elapsed: _stopwatch.elapsed,
      ),
    );
    _startTicker();
  }

  void _resetEvent(
    StopwatchEventReset event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.paused &&
        state.status != StopwatchStatus.finished) {
      return;
    }

    _cancelTicker();
    _stopwatch
      ..stop()
      ..reset();
    _lastSplitElapsed = Duration.zero;
    _lastLapElapsed = Duration.zero;
    emit(
      StopwatchState(
        maxLaps: state.maxLaps,
        splitsPerLap: state.splitsPerLap,
        snapshotRevision: state.snapshotRevision,
      ),
    );
  }

  void _splitEvent(
    StopwatchEventSplit event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.running) return;

    final elapsed = _stopwatch.elapsed;
    final splitDuration = elapsed - _lastSplitElapsed;
    _lastSplitElapsed = elapsed;
    final splitCount = _nextSplitCount(state.splitCount);
    final snapshot = SplitSnapshot.create(
      elapsed: elapsed,
      splitDuration: splitDuration,
      lapCount: state.lapCount,
      splitCount: splitCount,
    ).value!;

    emit(
      state.copyWith(
        elapsed: elapsed,
        splitCount: splitCount,
        snapshot: snapshot,
        snapshotRevision: state.snapshotRevision + 1,
      ),
    );
  }

  void _lapEvent(
    StopwatchEventLap event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.running) return;

    final elapsed = _stopwatch.elapsed;
    final splitDuration = elapsed - _lastSplitElapsed;
    final lapDuration = elapsed - _lastLapElapsed;
    _lastSplitElapsed = elapsed;
    _lastLapElapsed = elapsed;
    final lapCount = state.lapCount + 1;
    final splitCount = _nextSplitCount(state.splitCount);
    final lapSnapshot = LapSnapshot.create(
      elapsed: elapsed,
      splitDuration: splitDuration,
      lapDuration: lapDuration,
      lapCount: lapCount,
      splitCount: splitCount,
    ).value!;
    final revision = state.snapshotRevision + 1;

    emit(
      state.copyWith(
        elapsed: elapsed,
        lapCount: lapCount,
        splitCount: splitCount,
        snapshot: lapSnapshot,
        snapshotRevision: revision,
      ),
    );

    if (state.maxLaps != null && lapCount >= state.maxLaps!) {
      _stopwatch.stop();
      _cancelTicker();
      final finishSnapshot = FinishSnapshot.create(
        elapsed: elapsed,
        finalSplitDuration: splitDuration,
        finalLapDuration: lapDuration,
        lapCount: lapCount,
        splitCount: splitCount,
      ).value!;
      emit(
        state.copyWith(
          status: StopwatchStatus.finished,
          elapsed: elapsed,
          finishedAt: _now(),
          snapshot: finishSnapshot,
          snapshotRevision: revision + 1,
        ),
      );
    }
  }

  void _stopEvent(
    StopwatchEventStop event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.running &&
        state.status != StopwatchStatus.paused) {
      return;
    }

    if (state.status == StopwatchStatus.running) _stopwatch.stop();
    _cancelTicker();
    final elapsed = _stopwatch.elapsed;
    final splitDuration = elapsed - _lastSplitElapsed;
    final lapDuration = elapsed - _lastLapElapsed;
    _lastSplitElapsed = elapsed;
    _lastLapElapsed = elapsed;
    final lapCount = state.lapCount + 1;
    final splitCount = _nextSplitCount(state.splitCount);
    final snapshot = FinishSnapshot.create(
      elapsed: elapsed,
      finalSplitDuration: splitDuration,
      finalLapDuration: lapDuration,
      lapCount: lapCount,
      splitCount: splitCount,
    ).value!;

    emit(
      state.copyWith(
        status: StopwatchStatus.finished,
        elapsed: elapsed,
        lapCount: lapCount,
        splitCount: splitCount,
        finishedAt: _now(),
        snapshot: snapshot,
        snapshotRevision: state.snapshotRevision + 1,
      ),
    );
  }

  void _configureEvent(
    StopwatchEventConfigure event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.idle &&
        state.status != StopwatchStatus.finished) {
      return;
    }
    if (event.maxLaps != null && event.maxLaps! <= 0) return;
    if (event.splitsPerLap <= 0) return;

    emit(
      state.copyWith(
        maxLaps: event.maxLaps,
        splitsPerLap: event.splitsPerLap,
      ),
    );
  }

  void _tickEvent(
    _StopwatchEventTick event,
    Emitter<StopwatchState> emit,
  ) {
    if (state.status != StopwatchStatus.running) return;
    emit(state.copyWith(elapsed: _stopwatch.elapsed));
  }

  int _nextSplitCount(int current) {
    return current == state.splitsPerLap - 1 ? 0 : current + 1;
  }

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(
      _tickInterval,
      (_) {
        if (!isClosed) add(const _StopwatchEventTick());
      },
    );
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() async {
    _cancelTicker();
    _stopwatch.stop();
    await super.close();
  }
}

final class _StopwatchEventTick extends StopwatchEvent {
  const _StopwatchEventTick();
}
