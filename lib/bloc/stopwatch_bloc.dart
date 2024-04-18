import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signals/signals_flutter.dart';

import '../common/singletons/app_settings.dart';
import 'stopwatch_events.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvents, StopwatchState> {
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _lastLapTime;
  DateTime? _lastSplitTime;
  DateTime? _pausedTime;

  Duration _lapDuration = const Duration();
  Duration _splitDuration = const Duration();

  final _durationTrainingSignal = signal<Duration>(const Duration());
  final _lapCounter = signal<int>(0);
  final _splitCounter = signal<int>(0);
  int splitCounterMax = 99;

  Signal<Duration> get durationTraining => _durationTrainingSignal;
  Signal<int> get lapCounter => _lapCounter;
  Signal<int> get splitCounter => _splitCounter;
  DateTime get startTime => _startTime!;
  DateTime get endTime => _endTime!;
  Duration get lapDuration => _lapDuration;
  Duration get splitDuration => _splitDuration;

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
    final dateTimeNow = DateTime.now();

    if (state is StopwatchStatePaused) {
      // Is Paused Time
      final pausedDuration = dateTimeNow.difference(_pausedTime!);
      _updatePausedTimes(pausedDuration);
    } else {
      // Starting Time
      _restartTimesAndCounters(dateTimeNow);
    }
    _pausedTime = null;

    _timer = Timer.periodic(
        Duration(
          milliseconds: AppSettings.instance.millisecondRefresh,
        ), (timer) {
      _durationTrainingSignal.value = DateTime.now().difference(_startTime!);
    });
    emit(StopwatchStateRunning());
  }

  _updatePausedTimes(Duration pausedDuration) {
    _startTime = _startTime!.add(pausedDuration);
    _lastLapTime = _lastLapTime!.add(pausedDuration);
    _lastSplitTime = _lastSplitTime!.add(pausedDuration);
  }

  _restartTimesAndCounters(DateTime time) {
    _startTime = time;
    _endTime = null;
    _lastLapTime = time;
    _lastSplitTime = time;
    _lapCounter.value = 0;
    _splitCounter.value = 0;
  }

  FutureOr<void> _pauseEvent(
    StopwatchEventPause event,
    Emitter<StopwatchState> emit,
  ) async {
    final dateTimeNow = DateTime.now();
    _pausedTime = dateTimeNow;
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
    final now = DateTime.now();
    _updateLap(now);
    _updateSplit(now);

    emit(StopwatchStateRunning());
  }

  FutureOr<void> _splitEvent(
    StopwatchEventSplit event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is! StopwatchStateRunning) return;
    final now = DateTime.now();
    _updateSplit(now);

    emit(StopwatchStateRunning());
  }

  FutureOr<void> _stopEvent(
    StopwatchEventStop event,
    Emitter<StopwatchState> emit,
  ) async {
    final now = DateTime.now();
    _endTime = now;
    final pausedDuration = now.difference(_pausedTime!);
    _updatePausedTimes(pausedDuration);
    _updateLap(now);
    _updateSplit(now);

    emit(StopwatchStateInitial());
  }

  _updateLap(DateTime now) {
    _lapDuration = now.difference(_lastLapTime!);
    _lastLapTime = now;
    _lapCounter.value++;
  }

  _updateSplit(DateTime now) {
    _splitDuration = now.difference(_lastSplitTime!);
    _lastSplitTime = now;

    if (_splitCounter() == splitCounterMax - 1) {
      _splitCounter.value = 0;
    } else {
      _splitCounter.value++;
    }
  }
}
