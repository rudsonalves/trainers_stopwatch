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
  final _lapCounter = signal<int>(0);
  final _splitCounter = signal<int>(0);
  int splitCounterMax = 99;

  Signal<Duration> get durationTraining => _durationTrainingSignal;
  Signal<int> get lapCounter => _lapCounter;
  Signal<int> get splitCounter => _splitCounter;

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
    _lapCounter.dispose();
    _splitCounter.dispose();
  }

  FutureOr<void> _startEvent(
    StopwatchEventRun event,
    Emitter<StopwatchState> emit,
  ) async {
    if (_timer != null && _timer!.isActive) return;

    if (state is StopwatchStatePaused) {
      final pausedDuration = DateTime.now().difference(_pausedTime!);
      _startTime = _startTime!.add(pausedDuration);
    } else {
      _startTime = DateTime.now();
      _lapCounter.value = 0;
      _splitCounter.value = 0;
    }
    _pausedTime = null;

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
    _lapCounter.value = 0;
    _splitCounter.value = 0;

    emit(StopwatchStateReset());
  }

  FutureOr<void> _lapEvent(
    StopwatchEventLap event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    _lapCounter.value++;
    _splitCounter.value = 0;

    emit(StopwatchStateRunning());
  }

  FutureOr<void> _splitEvent(
    StopwatchEventSplit event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    _splitCounter.value++;

    emit(StopwatchStateRunning());
  }

  FutureOr<void> _stopEvent(
    StopwatchEventStop event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStatePaused) return;

    _lapCounter.value++;
    _splitCounter.value++;
    emit(StopwatchStateInitial());
  }
}
