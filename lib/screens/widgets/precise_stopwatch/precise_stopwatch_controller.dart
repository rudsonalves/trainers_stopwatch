import 'package:flutter/foundation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_events.dart';
import '../../../bloc/stopwatch_state.dart';
import '../../../common/singletons/app_settings.dart';
import '../../../manager/history_manager.dart';
import '../../../manager/training_manager.dart';
import '../../../models/athlete_model.dart';
import '../../../models/history_model.dart';
import '../../../models/training_model.dart';
import '../../stopwatch_page/stopwatch_page_controller.dart';

class PreciseStopwatchController {
  final _bloc = StopwatchBloc();
  final _trainingManager = TrainingManager();
  final _historyManager = HistoryManager();
  late final AthleteModel _athlete;
  late TrainingModel _training;
  int _lastLapMS = 0;
  int _lastSplitMS = 0;
  bool _trainingStarted = false;
  late double splitLength;
  late double lapLength;
  final _actionOnPress = ValueNotifier<bool>(false);

  final _stopwatchController = StopwatchPageController.instance;

  StopwatchBloc get bloc => _bloc;
  StopwatchState get state => _bloc.state;
  Signal<int> get counter => _bloc.counter;
  Signal<Duration> get durationTraining => _bloc.durationTraining;
  AthleteModel get athlete => _athlete;
  List<TrainingModel> get trainings => _trainingManager.trainings;
  List<HistoryModel> get histories => _historyManager.histories;
  TrainingModel get training => _training;
  ValueNotifier<bool> get actionOnPress => _actionOnPress;

  Future<void> init(AthleteModel athlete) async {
    _athlete = athlete;
    splitLength = AppSettings.instance.splitLength;
    lapLength = AppSettings.instance.lapLength;
    _trainingManager.init(_athlete.id!);
    _createNewTraining();
  }

  void dispose() {
    _bloc.dispose();
    _actionOnPress.dispose();
    counter.dispose();
    durationTraining.dispose();
  }

  void _toggleActionOnPress() {
    _actionOnPress.value = !_actionOnPress.value;
  }

  Future<void> _createNewTraining() async {
    _training = TrainingModel(
      athleteId: _athlete.id!,
      date: DateTime.now(),
      splitLength: splitLength,
      lapLength: lapLength,
    );

    await _trainingManager.insert(_training);
    _historyManager.setTrainingId(_training.id!);
    _trainingStarted = true;
  }

  void updateSplitLapLength() {
    if (splitLength != _training.splitLength) {
      splitLength = training.splitLength;
    }
    if (lapLength != _training.lapLength) {
      lapLength = training.lapLength;
    }
  }

  Future<void> blocStartTimer() async {
    _bloc.add(StopwatchEventRun());

    if (!_trainingStarted) {
      await _createNewTraining();
      _toggleActionOnPress();
    }
  }

  void blocPauseTimer() {
    _bloc.add(StopwatchEventPause());
    _toggleActionOnPress();
  }

  void blocResetTimer() {
    _bloc.add(StopwatchEventReset());
    _toggleActionOnPress();
  }

  Future<void> blocNextLap() async {
    if (_bloc.state is! StopwatchStateRunning) return;
    _bloc.add(StopwatchEventLap());

    if (!_trainingStarted) return;

    await Future.delayed(const Duration(milliseconds: 50));

    int lapMs;
    double speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: lapMs),
      lap: counter(),
    );

    _createMassage(history.duration, speed, history.lap);
    await _historyManager.insert(history);
    _toggleActionOnPress();
  }

  Future<void> blocSplitTimer() async {
    if (_bloc.state is! StopwatchStateRunning) return;
    _bloc.add(StopwatchEventSplit());

    if (!_trainingStarted) return;

    await Future.delayed(const Duration(milliseconds: 50));

    int splitMs;
    double speed;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: splitMs),
    );

    _createMassage(history.duration, speed);

    await _historyManager.insert(history);
    _toggleActionOnPress();
  }

  Future<void> blocStopTimer() async {
    _bloc.add(StopwatchEventStop());
    _trainingStarted = false;

    await Future.delayed(const Duration(milliseconds: 50));

    int lapMs;
    double speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel historyLap = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: lapMs),
      lap: counter(),
    );

    _createMassage(historyLap.duration, speed, historyLap.lap);

    await Future.delayed(const Duration(milliseconds: 1500));

    int splitMs;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    HistoryModel historySpli = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: splitMs),
    );

    _createMassage(historySpli.duration, speed);

    await _historyManager.insert(historyLap);
    await _historyManager.insert(historySpli);
    _toggleActionOnPress();
  }

  String formatMs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 4);
  }

  String formatCs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 3);
  }

  void _createMassage(
    Duration time,
    double speed, [
    int? lap,
  ]) {
    String message = '';
    if (lap != null) {
      message = speed != 0
          ? 'Lap [$lap]: ${formatMs(time)}'
              ' speed: ${speed.toStringAsFixed(2)} m/s'
          : 'Lap [$lap]: ${formatMs(time)}';
    } else {
      message = speed != 0
          ? 'Split: ${formatMs(time)}'
              ' speed: ${speed.toStringAsFixed(2)} m/s'
          : 'Split: ${formatMs(time)}';
    }
    _stopwatchController.sendSnackBarMessage(message);
  }

  (int, double) _calculateLapTimeSpeed() {
    final lapMS = durationTraining().inMilliseconds - _lastLapMS;
    _lastLapMS = durationTraining().inMilliseconds;

    final speed = 1000 * _training.lapLength / lapMS;
    return (lapMS, speed);
  }

  (int, double) _calculateSplitTimeSpeed() {
    final splitMS = durationTraining().inMilliseconds - _lastSplitMS;
    _lastSplitMS = durationTraining().inMilliseconds;

    final speed = 1000 * _training.splitLength / splitMS;
    return (splitMS, speed);
  }

  String speedCalc({
    required Duration duration,
    required double distante,
    required String distanceUnit,
    required String speedUnit,
  }) {
    final double time = duration.inMilliseconds / 1000;

    double length = distante;
    switch (distanceUnit) {
      case 'km':
        length *= 1000;
        break;
      case 'yd':
        length *= 0.9144;
        break;
      case 'mi':
        length *= 1609.34;
        break;
    }

    double speed = length / time;
    switch (speedUnit) {
      case 'yd/s':
        speed *= 1.09361;
        break;
      case 'km/h':
        speed *= 3.6;
        break;
      case 'mph':
        speed *= 2.23694;
        break;
    }

    return '${speed.toStringAsFixed(2)} $speedUnit';
  }
}
