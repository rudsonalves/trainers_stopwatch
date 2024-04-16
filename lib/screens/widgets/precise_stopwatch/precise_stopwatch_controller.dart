import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
  bool isPaused = false;
  late double splitLength;
  late double lapLength;
  final _actionOnPress = ValueNotifier<bool>(false);

  final _stopwatchController = StopwatchPageController.instance;

  StopwatchBloc get bloc => _bloc;
  StopwatchState get state => _bloc.state;
  Signal<int> get lapCounter => _bloc.lapCounter;
  Signal<int> get splitCounter => _bloc.splitCounter;
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
    _bloc.splitCounterMax = lapLength ~/ splitLength;
    _trainingManager.init(_athlete.id!);
    _createNewTraining();
  }

  void dispose() {
    _bloc.dispose();
    _actionOnPress.dispose();
    lapCounter.dispose();
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

    _bloc.splitCounterMax = lapLength ~/ splitLength;
  }

  Future<void> blocStartTimer() async {
    _bloc.add(StopwatchEventRun());

    if (isPaused) {
      isPaused = false;
      return;
    }

    if (!_trainingStarted) {
      await _createNewTraining();
    }

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: const Duration(milliseconds: 0),
      lap: 0,
      split: 0,
    );
    _lastLapMS = 0;
    _lastSplitMS = 0;

    await _historyManager.insert(history);
    _toggleActionOnPress();
    _sendStartedMessage();
  }

  void blocPauseTimer() {
    _bloc.add(StopwatchEventPause());
    isPaused = true;
  }

  void blocResetTimer() {
    _bloc.add(StopwatchEventReset());
    _toggleActionOnPress();
  }

  Future<void> blocLapTimer() async {
    if (_bloc.state is! StopwatchStateRunning) return;
    _bloc.add(StopwatchEventLap());

    await _generateSplitRegister(bloc.splitCounterMax);
    await _generateLapRegister();
  }

  Future<void> blocSplitTimer() async {
    if (_bloc.state is! StopwatchStateRunning) return;
    _bloc.add(StopwatchEventSplit());

    await _generateSplitRegister();
  }

  Future<void> blocStopTimer() async {
    _bloc.add(StopwatchEventStop());
    isPaused = false;

    await _generateSplitRegister();

    await _generateLapRegister();

    _trainingStarted = false;

    _sendFinishMessage();
    _toggleActionOnPress();
  }

  Future<void> _generateSplitRegister([int? split]) async {
    if (!_trainingStarted) return;

    await Future.delayed(const Duration(milliseconds: 50));

    int splitMs;
    String speed;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: splitMs),
      split: split ?? _bloc.splitCounter(),
      comments: 'Speed: $speed',
    );

    await _historyManager.insert(history);
    _sendSplitMessage(history.duration, speed, split);
    _toggleActionOnPress();
  }

  Future<void> _generateLapRegister() async {
    if (!_trainingStarted) return;

    await Future.delayed(const Duration(milliseconds: 50));

    int lapMs;
    String speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training.id!,
      duration: Duration(milliseconds: lapMs),
      lap: lapCounter(),
      split: _bloc.splitCounter(),
      comments: 'Speed: $speed',
    );

    await _historyManager.insert(history);
    _sendLapMessage(history.duration, speed, history.lap!);
    _toggleActionOnPress();
  }

  String _formatMs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 4);
  }

  String formatCs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 3);
  }

  void _sendStartedMessage() {
    final message = '${athlete.name}\n'
        'Started training at ${DateFormat.Hms().format(DateTime.now())}';
    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendSplitMessage(
    Duration time,
    String speed, [
    int? split,
  ]) {
    final message = '${athlete.name}\n'
        'Split [${split ?? splitCounter()}]: ${_formatMs(time)}'
        ' speed: $speed';
    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendLapMessage(
    Duration time,
    String speed,
    int lap,
  ) {
    final message = '${athlete.name}\n'
        'Lap [$lap]: ${_formatMs(time)}'
        ' speed: $speed';
    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendFinishMessage() {
    final message = '${athlete.name}\n'
        'Fininshed training at ${DateFormat.Hms().format(DateTime.now())}';
    _stopwatchController.sendHistoryMessage(message);
  }

  (int, String) _calculateLapTimeSpeed() {
    final lapMS = durationTraining().inMilliseconds - _lastLapMS;
    _lastLapMS = durationTraining().inMilliseconds;

    final speed = speedCalc(training.lapLength, lapMS / 1000);

    return (lapMS, speed);
  }

  (int, String) _calculateSplitTimeSpeed() {
    final splitMS = durationTraining().inMilliseconds - _lastSplitMS;
    _lastSplitMS = durationTraining().inMilliseconds;

    final speed = speedCalc(training.splitLength, splitMS / 1000);
    return (splitMS, speed);
  }

  String speedCalc(
    double length,
    double time,
  ) {
    switch (training.distanceUnit) {
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
    switch (training.speedUnit) {
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

    return '${speed.toStringAsFixed(2)} ${training.speedUnit}';
  }
}
