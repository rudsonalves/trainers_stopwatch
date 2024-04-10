import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signals/signals_flutter.dart';

import 'stopwatch_events.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvents, StopwatchState> {
  static int millisecondRefresh = 66;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _lastSplitTime;
  DateTime? _lastLapTime;
  DateTime? _pausedTime;
  final _elapsedDuration = signal<Duration>(const Duration());
  final _counter = signal<int>(0);

  Signal<Duration> get elapsedDuration => _elapsedDuration;
  Signal<int> get counter => _counter;

  StopwatchBloc() : super(StopwatchStateInitial()) {
    on<StopwatchEventRun>(_startEvent);
    on<StopwatchEventPause>(_pauseEvent);
    on<StopwatchEventReset>(_resetEvent);
    on<StopwatchEventLap>(_lapEvent);
    on<StopwatchEventSplit>(_splitEvent);
    on<StopwatchEventStop>(_stopEvent);
  }

  void init() {}

  void dispose() {
    _timer?.cancel();
    _elapsedDuration.dispose();
    _counter.dispose();
  }

  FutureOr<void> _startEvent(
    StopwatchEventRun event,
    Emitter<StopwatchState> emit,
  ) async {
    if (_timer != null && _timer!.isActive) return;

    if (state is StopwatchStatePaused) {
      final pausedDuration = DateTime.now().difference(_pausedTime!);
      _startTime = _startTime!.add(pausedDuration);
      _lastSplitTime = _lastSplitTime!.add(pausedDuration);
      _lastLapTime = _lastLapTime!.add(pausedDuration);
      _pausedTime = null;
    } else {
      _startTime = DateTime.now();
      _lastSplitTime = _startTime;
      _lastLapTime = _startTime;
      _counter.value = 0;
    }

    _timer = Timer.periodic(
        Duration(
          milliseconds: millisecondRefresh,
        ), (timer) {
      final now = DateTime.now();
      _elapsedDuration.value = now.difference(_startTime!);
    });
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _pauseEvent(
    StopwatchEventPause event,
    Emitter<StopwatchState> emit,
  ) async {
    _pausedTime = DateTime.now();
    _elapsedDuration.value = _pausedTime!.difference(_startTime!);

    _timer?.cancel();
    emit(StopwatchStatePaused());
  }

  FutureOr<void> _resetEvent(
    StopwatchEventReset event,
    Emitter<StopwatchState> emit,
  ) async {
    _timer?.cancel();
    _elapsedDuration.value = const Duration();
    _counter.value = 0;
    _lastSplitTime = null;
    emit(StopwatchStateReset());
  }

  FutureOr<void> _lapEvent(
    StopwatchEventLap event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    final now = DateTime.now();
    _counter.value++;
    final lapTime = now.difference(_lastLapTime!);
    _lastLapTime = now;
    log('Lap (${_counter()}): ${lapTime.toString()}');
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _splitEvent(
    StopwatchEventSplit event,
    Emitter<StopwatchState> emit,
  ) async {
    final now = DateTime.now();
    final split = now.difference(_lastSplitTime!);
    _lastSplitTime = now;
    log('Split: ${split.toString()}');
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _stopEvent(
    StopwatchEventStop event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStatePaused) return;
    final split = _pausedTime!.difference(_lastSplitTime!);
    final lapTime = _pausedTime!.difference(_lastLapTime!);
    final totalTime = _pausedTime!.difference(_startTime!);

    log('Last Lap (${counter() + 1}): ${lapTime.toString()}');
    log('Last Split: ${split.toString()}');
    log('Total Time: ${totalTime.toString()}');

    _lastSplitTime = null;
    _lastLapTime = null;
    _counter.value++;
    _lastSplitTime = null;
    emit(StopwatchStateInitial());
  }
}
