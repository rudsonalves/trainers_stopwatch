import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signals/signals_flutter.dart';

import '../common/singletons/app_settings.dart';
import 'stopwatch_events.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvents, StopwatchState> {
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _pausedTime;

  final _durationTrainingSignal = signal<Duration>(const Duration());
  final _counter = signal<int>(0);

  Signal<Duration> get durationTraining => _durationTrainingSignal;
  Signal<int> get counter => _counter;

  StopwatchBloc() : super(StopwatchStateInitial()) {
    on<StopwatchEventRun>(_startEvent);
    on<StopwatchEventPause>(_pauseEvent);
    on<StopwatchEventReset>(_resetEvent);
    on<StopwatchEventLap>(_lapEvent);
    on<StopwatchEventSplit>(_splitEvent);
    on<StopwatchEventStop>(_stopEvent);
  }

  void dispose() {
    _timer?.cancel();
    _durationTrainingSignal.dispose();
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
      _pausedTime = null;
    } else {
      _startTime = DateTime.now();
      _counter.value = 0;
    }

    _timer = Timer.periodic(
        Duration(
          milliseconds: AppSettings.instance.millisecondRefresh,
        ), (timer) {
      final now = DateTime.now();
      _durationTrainingSignal.value = now.difference(_startTime!);
    });
    emit(StopwatchStateRunning());
  }

  FutureOr<void> _pauseEvent(
    StopwatchEventPause event,
    Emitter<StopwatchState> emit,
  ) async {
    _pausedTime = DateTime.now();
    _durationTrainingSignal.value = _pausedTime!.difference(_startTime!);

    _timer?.cancel();
    emit(StopwatchStatePaused());
  }

  FutureOr<void> _resetEvent(
    StopwatchEventReset event,
    Emitter<StopwatchState> emit,
  ) async {
    _timer?.cancel();
    _durationTrainingSignal.value = const Duration();
    _counter.value = 0;

    emit(StopwatchStateReset());
  }

  FutureOr<void> _lapEvent(
    StopwatchEventLap event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    _counter.value++;

    emit(StopwatchStateRunning());
  }

  FutureOr<void> _splitEvent(
    StopwatchEventSplit event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;

    emit(StopwatchStateRunning());
  }

  FutureOr<void> _stopEvent(
    StopwatchEventStop event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStatePaused) return;

    _counter.value++;
    emit(StopwatchStateInitial());
  }
}
