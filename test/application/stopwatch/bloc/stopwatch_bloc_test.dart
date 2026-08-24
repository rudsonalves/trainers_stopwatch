import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_bloc.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_event.dart';
import 'package:trainers_stopwatch/application/stopwatch/bloc/stopwatch_state.dart';
import 'package:trainers_stopwatch/domain/common/stopwatch/models/stopwatch_snapshot.dart';

void main() {
  group('StopwatchBloc', () {
    testWidgets('uses monotonic elapsed for ticks, pause and resume',
        (tester) async {
      final source = ControlledStopwatch();
      final startedAt = DateTime.utc(2026, 8, 24, 12);
      final bloc = StopwatchBloc(
        now: () => startedAt,
        createStopwatch: () => source,
      );
      addTearDown(bloc.close);

      await dispatch(
        bloc,
        const StopwatchEventRun(),
        (state) => state.status == StopwatchStatus.running,
      );
      expect(bloc.state.startedAt, startedAt);

      source.advance(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
      expect(bloc.state.elapsed, const Duration(seconds: 3));

      await dispatch(
        bloc,
        const StopwatchEventPause(),
        (state) => state.status == StopwatchStatus.paused,
      );
      source.advance(const Duration(seconds: 8));
      await tester.pump(const Duration(milliseconds: 100));
      expect(bloc.state.elapsed, const Duration(seconds: 3));

      await dispatch(
        bloc,
        const StopwatchEventResume(),
        (state) => state.status == StopwatchStatus.running,
      );
      source.advance(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
      expect(bloc.state.elapsed, const Duration(seconds: 5));
      await dispatch(
        bloc,
        const StopwatchEventPause(),
        (state) => state.status == StopwatchStatus.paused,
      );
    });

    test('tick quantity never changes the measured duration', () {
      fakeAsync((async) {
        final source = ControlledStopwatch();
        final bloc = StopwatchBloc(createStopwatch: () => source);

        bloc.add(const StopwatchEventRun());
        async.flushMicrotasks();
        source.advance(const Duration(seconds: 7));
        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();
        expect(bloc.state.elapsed, const Duration(seconds: 7));

        async.elapse(const Duration(milliseconds: 500));
        async.flushMicrotasks();
        expect(bloc.state.elapsed, const Duration(seconds: 7));

        bloc.close();
        async.flushMicrotasks();
      });
    });

    test('creates split and lap snapshots from monotonic differences',
        () async {
      final source = ControlledStopwatch();
      final bloc = StopwatchBloc(
        createStopwatch: () => source,
        splitsPerLap: 2,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      source.advance(const Duration(seconds: 4));
      final splitState = await dispatch(
        bloc,
        const StopwatchEventSplit(),
        (state) => state.snapshot is SplitSnapshot,
      );
      final split = splitState.snapshot! as SplitSnapshot;
      expect(split.splitDuration, const Duration(seconds: 4));
      expect(splitState.splitCount, 1);

      source.advance(const Duration(seconds: 6));
      final lapState = await dispatch(
        bloc,
        const StopwatchEventLap(),
        (state) => state.snapshot is LapSnapshot,
      );
      final lap = lapState.snapshot! as LapSnapshot;
      expect(lap.splitDuration, const Duration(seconds: 6));
      expect(lap.lapDuration, const Duration(seconds: 10));
      expect(lapState.lapCount, 1);
      expect(lapState.splitCount, 0);

      source.advance(const Duration(seconds: 7));
      final nextLapState = await dispatch(
        bloc,
        const StopwatchEventLap(),
        (state) => state.snapshotRevision > lapState.snapshotRevision,
      );
      final nextLap = nextLapState.snapshot! as LapSnapshot;
      expect(nextLap.splitDuration, const Duration(seconds: 7));
      expect(nextLap.lapDuration, const Duration(seconds: 7));
    });

    test('handles consecutive splits and resets their cycle', () async {
      final source = ControlledStopwatch();
      final bloc = StopwatchBloc(
        createStopwatch: () => source,
        splitsPerLap: 3,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      for (final seconds in [2, 3, 4]) {
        source.advance(Duration(seconds: seconds));
        final revision = bloc.state.snapshotRevision;
        await dispatch(
          bloc,
          const StopwatchEventSplit(),
          (state) => state.snapshotRevision > revision,
        );
      }

      expect(bloc.state.splitCount, 0);
      expect(
        (bloc.state.snapshot! as SplitSnapshot).splitDuration,
        const Duration(seconds: 4),
      );
    });

    test('finishes while running and preserves civil and monotonic values',
        () async {
      final source = ControlledStopwatch();
      final finishedAt = DateTime.utc(2026, 8, 24, 13);
      var now = DateTime.utc(2026, 8, 24, 12);
      final bloc = StopwatchBloc(
        now: () => now,
        createStopwatch: () => source,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      source.advance(const Duration(seconds: 12));
      now = finishedAt;
      final state = await dispatch(
        bloc,
        const StopwatchEventStop(),
        (state) => state.status == StopwatchStatus.finished,
      );

      expect(source.isRunning, isFalse);
      expect(state.elapsed, const Duration(seconds: 12));
      expect(state.finishedAt, finishedAt);
      final snapshot = state.snapshot! as FinishSnapshot;
      expect(snapshot.finalSplitDuration, const Duration(seconds: 12));
      expect(snapshot.finalLapDuration, const Duration(seconds: 12));
    });

    test('finishes while paused without counting the paused period', () async {
      final source = ControlledStopwatch();
      final bloc = StopwatchBloc(
        createStopwatch: () => source,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      source.advance(const Duration(seconds: 9));
      await dispatch(
        bloc,
        const StopwatchEventPause(),
        (state) => state.status == StopwatchStatus.paused,
      );
      source.advance(const Duration(minutes: 1));
      final state = await dispatch(
        bloc,
        const StopwatchEventStop(),
        (state) => state.status == StopwatchStatus.finished,
      );

      expect(state.elapsed, const Duration(seconds: 9));
      expect((state.snapshot! as FinishSnapshot).finalLapDuration,
          const Duration(seconds: 9));
    });

    test('resets to idle and starts a clean measurement after finish',
        () async {
      final source = ControlledStopwatch();
      final bloc = StopwatchBloc(
        createStopwatch: () => source,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      source.advance(const Duration(seconds: 5));
      final finished = await dispatch(
        bloc,
        const StopwatchEventStop(),
        (state) => state.status == StopwatchStatus.finished,
      );
      final idle = await dispatch(
        bloc,
        const StopwatchEventReset(),
        (state) => state.status == StopwatchStatus.idle,
      );

      expect(idle.elapsed, Duration.zero);
      expect(idle.lapCount, 0);
      expect(idle.splitCount, 0);
      expect(idle.snapshot, isNull);
      expect(idle.snapshotRevision, finished.snapshotRevision);

      final running = await dispatch(
        bloc,
        const StopwatchEventRun(),
        isRunning,
      );
      expect(running.elapsed, Duration.zero);
      expect(source.elapsed, Duration.zero);
    });

    test('emits lap then finish when maximum laps is reached', () async {
      final source = ControlledStopwatch();
      final bloc = StopwatchBloc(
        createStopwatch: () => source,
        maxLaps: 1,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);
      final emitted = <StopwatchState>[];
      final subscription = bloc.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      source.advance(const Duration(seconds: 20));
      await dispatch(
        bloc,
        const StopwatchEventLap(),
        (state) => state.status == StopwatchStatus.finished,
      );

      final snapshots = emitted
          .map((state) => state.snapshot)
          .whereType<StopwatchSnapshot>()
          .toList();
      expect(snapshots.whereType<LapSnapshot>(), hasLength(1));
      expect(snapshots.whereType<FinishSnapshot>(), hasLength(1));
      expect(bloc.state.lapCount, 1);
      expect(source.isRunning, isFalse);
    });

    test('cancels ticker on pause and close', () {
      fakeAsync((async) {
        final source = ControlledStopwatch();
        final bloc = StopwatchBloc(createStopwatch: () => source);
        final emitted = <StopwatchState>[];
        final subscription = bloc.stream.listen(emitted.add);

        bloc.add(const StopwatchEventRun());
        async.flushMicrotasks();
        source.advance(const Duration(seconds: 1));
        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();
        expect(bloc.state.elapsed, const Duration(seconds: 1));

        bloc.add(const StopwatchEventPause());
        async.flushMicrotasks();
        final afterPause = emitted.length;
        async.elapse(const Duration(milliseconds: 200));
        async.flushMicrotasks();
        expect(emitted, hasLength(afterPause));

        bloc.add(const StopwatchEventResume());
        async.flushMicrotasks();
        bloc.close();
        async.flushMicrotasks();
        expect(bloc.isClosed, isTrue);
        final afterClose = emitted.length;
        async.elapse(const Duration(milliseconds: 200));
        async.flushMicrotasks();
        expect(emitted, hasLength(afterClose));
        expect(source.isRunning, isFalse);
        subscription.cancel();
      });
    });

    test('ignores invalid and repeated events without emitting', () async {
      final source = ControlledStopwatch();
      final bloc = StopwatchBloc(
        createStopwatch: () => source,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(bloc.close);
      final emitted = <StopwatchState>[];
      final subscription = bloc.stream.listen(emitted.add);
      addTearDown(subscription.cancel);

      bloc
        ..add(const StopwatchEventPause())
        ..add(const StopwatchEventResume())
        ..add(const StopwatchEventSplit())
        ..add(const StopwatchEventLap())
        ..add(const StopwatchEventStop())
        ..add(const StopwatchEventReset());
      await Future<void>.delayed(Duration.zero);
      expect(emitted, isEmpty);

      await dispatch(bloc, const StopwatchEventRun(), isRunning);
      final afterRun = emitted.length;
      bloc
        ..add(const StopwatchEventRun())
        ..add(const StopwatchEventResume())
        ..add(const StopwatchEventReset())
        ..add(const StopwatchEventConfigure(maxLaps: 2, splitsPerLap: 2));
      await Future<void>.delayed(Duration.zero);
      expect(emitted, hasLength(afterRun));
    });

    test('keeps different bloc instances temporally independent', () async {
      final firstSource = ControlledStopwatch();
      final secondSource = ControlledStopwatch();
      final first = StopwatchBloc(
        createStopwatch: () => firstSource,
        tickInterval: const Duration(days: 1),
      );
      final second = StopwatchBloc(
        createStopwatch: () => secondSource,
        tickInterval: const Duration(days: 1),
      );
      addTearDown(first.close);
      addTearDown(second.close);

      await dispatch(first, const StopwatchEventRun(), isRunning);
      await dispatch(second, const StopwatchEventRun(), isRunning);
      firstSource.advance(const Duration(seconds: 3));
      secondSource.advance(const Duration(seconds: 8));

      final firstSplit = await dispatch(
        first,
        const StopwatchEventSplit(),
        (state) => state.snapshot is SplitSnapshot,
      );
      final secondSplit = await dispatch(
        second,
        const StopwatchEventSplit(),
        (state) => state.snapshot is SplitSnapshot,
      );

      expect(firstSplit.elapsed, const Duration(seconds: 3));
      expect(secondSplit.elapsed, const Duration(seconds: 8));
      expect(firstSplit.snapshotRevision, 1);
      expect(secondSplit.snapshotRevision, 1);
    });
  });

  test('StopwatchState has value equality and can clear nullable values', () {
    final startedAt = DateTime.utc(2026, 8, 24);
    final state = StopwatchState(
      status: StopwatchStatus.running,
      startedAt: startedAt,
      maxLaps: 3,
    );

    expect(
      state,
      StopwatchState(
        status: StopwatchStatus.running,
        startedAt: startedAt,
        maxLaps: 3,
      ),
    );
    expect(state.copyWith(startedAt: null, maxLaps: null).startedAt, isNull);
    expect(state.copyWith(startedAt: null, maxLaps: null).maxLaps, isNull);
  });
}

bool isRunning(StopwatchState state) => state.status == StopwatchStatus.running;

Future<StopwatchState> dispatch(
  StopwatchBloc bloc,
  StopwatchEvent event,
  bool Function(StopwatchState state) matches,
) {
  final nextState = bloc.stream.firstWhere(matches);
  bloc.add(event);
  return nextState;
}

final class ControlledStopwatch implements Stopwatch {
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
