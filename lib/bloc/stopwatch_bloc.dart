import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'stopwatch_events.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvents, StopwatchState> {
  static int millisecondRefresh = 66;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _pausedTime;
  final _elapsed = ValueNotifier<Duration>(const Duration());
  final _counter = ValueNotifier<int>(0);

  ValueNotifier<Duration> get elapsed => _elapsed;
  ValueNotifier<int> get counter => _counter;

  StopwatchBloc() : super(StopwatchStateInitial()) {
    on<StopwatchEventRun>(_startStopwatch);
    on<StopwatchEventPause>(_pauseStopwatch);
    on<StopwatchEventReset>(_resetStopwatch);
    on<StopwatchEventCounterIncrement>(_incrementCounter);
    on<StopwatchEventCounterDecrement>(_decrementCounter);
    on<StopwatchEventCounterReset>(_resetCounter);
  }

  void init() {}

  void dispose() {
    _timer?.cancel();
    _elapsed.dispose();
    _counter.dispose();
  }

  FutureOr<void> _startStopwatch(
    StopwatchEventRun event,
    Emitter<StopwatchState> emit,
  ) async {
    if (_timer != null && _timer!.isActive) return;

    if (state is StopwatchStatePaused) {
      final pausedDuration = DateTime.now().difference(_pausedTime!);
      _startTime = _startTime!.add(pausedDuration);
      _pausedTime = null;
    } else {
      _startTime = DateTime.now();
    }

    _timer = Timer.periodic(
        Duration(
          milliseconds: millisecondRefresh,
        ), (timer) {
      final now = DateTime.now();
      _elapsed.value = now.difference(_startTime!);
    });
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _pauseStopwatch(
    StopwatchEventPause event,
    Emitter<StopwatchState> emit,
  ) async {
    _pausedTime = DateTime.now();
    _timer?.cancel();
    emit(StopwatchStatePaused());
  }

  FutureOr<void> _resetStopwatch(
    StopwatchEventReset event,
    Emitter<StopwatchState> emit,
  ) async {
    _timer?.cancel();
    _elapsed.value = const Duration();
    emit(StopwatchStateReset());
  }

  FutureOr<void> _incrementCounter(
    StopwatchEventCounterIncrement event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    _counter.value++;
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _decrementCounter(
    StopwatchEventCounterDecrement event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    if (_counter.value > 0) {
      _counter.value--;
    }
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _resetCounter(
    StopwatchEventCounterReset event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    _counter.value = 0;
    emit(StopwatchStateRunning());
  }
}
