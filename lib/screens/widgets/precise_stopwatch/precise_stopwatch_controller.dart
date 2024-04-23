import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:signals/signals_flutter.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_events.dart';
import '../../../bloc/stopwatch_state.dart';
import '../../../common/functions/stopwatch_functions.dart';
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
  TrainingModel? _training;
  bool isPaused = false;
  late double splitLength;
  late double lapLength;
  final _actionOnPress = ValueNotifier<bool>(false);
  bool _isCreatedTraining = false;

  final _stopwatchController = StopwatchPageController.instance;

  StopwatchBloc get bloc => _bloc;
  StopwatchState get state => _bloc.state;
  Signal<int> get lapCounter => _bloc.lapCounter;
  Signal<int> get splitCounter => _bloc.splitCounter;
  Signal<Duration> get durationTraining => _bloc.durationTraining;
  AthleteModel get athlete => _athlete;
  List<TrainingModel> get trainings => _trainingManager.trainings;
  List<HistoryModel> get histories => _historyManager.histories;
  TrainingModel get training => _training!;
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

  void _createNewTraining() {
    _training = TrainingModel(
      athleteId: _athlete.id!,
      date: DateTime.now(),
      splitLength: splitLength,
      lapLength: lapLength,
    );
    _isCreatedTraining = true;
  }

  Future<void> _insertTraining() async {
    if (training.id != null) {
      throw Exception('Error!!!');
    }
    _training!.date = bloc.startTime;
    await _trainingManager.insert(_training!);
    _historyManager.init(_training!.id!);
  }

  void updateSplitLapLength() {
    if (splitLength != _training!.splitLength) {
      splitLength = training.splitLength;
    }
    if (lapLength != _training!.lapLength) {
      lapLength = training.lapLength;
    }

    _bloc.splitCounterMax = lapLength ~/ splitLength;
  }

  Future<void> blocStartTimer() async {
    _bloc.add(StopwatchEventRun());
    await Future.delayed(const Duration(milliseconds: 100));

    if (isPaused) {
      isPaused = false;
      return;
    }

    if (!_isCreatedTraining) {
      _createNewTraining();
    }
    await _insertTraining();

    HistoryModel history = HistoryModel(
      trainingId: _training!.id!,
      duration: const Duration(milliseconds: 0),
      lap: 0,
      split: 0,
    );

    await _historyManager.insert(history);
    _toggleActionOnPress();
    _sendStartedMessage();
  }

  Future<void> blocPauseTimer() async {
    _bloc.add(StopwatchEventPause());
    await Future.delayed(const Duration(milliseconds: 100));
    isPaused = true;
  }

  Future<void> blocResetTimer() async {
    _bloc.add(StopwatchEventReset());
    await Future.delayed(const Duration(milliseconds: 100));
    _toggleActionOnPress();
  }

  Future<void> blocLapTimer() async {
    _bloc.add(StopwatchEventLap());
    await Future.delayed(const Duration(milliseconds: 100));

    await _generateSplitRegister();
    await _generateLapRegister();

    if (_bloc.maxLaps != null && _bloc.maxLaps == _bloc.lapCounter()) {
      isPaused = false;
      _isCreatedTraining = false;
      _sendFinishMessage();
      _toggleActionOnPress();
      _createNewTraining();
    }
  }

  Future<void> blocSplitTimer() async {
    _bloc.add(StopwatchEventSplit());
    await Future.delayed(const Duration(milliseconds: 100));

    await _generateSplitRegister();
  }

  Future<void> blocStopTimer() async {
    _bloc.add(StopwatchEventStop());
    await Future.delayed(const Duration(milliseconds: 100));

    isPaused = false;
    _isCreatedTraining = false;

    await _generateSplitRegister();
    await _generateLapRegister();

    _sendFinishMessage();
    _toggleActionOnPress();
    _createNewTraining();
  }

  Future<void> _generateSplitRegister() async {
    int splitMs;
    String speed;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    int split = _getSplit();

    HistoryModel history = HistoryModel(
      trainingId: _training!.id!,
      duration: Duration(milliseconds: splitMs),
      split: split,
      comments: 'PSCHistoryComments'.tr(args: [speed]),
    );

    await _historyManager.insert(history);
    _sendSplitMessage(history.duration, speed, split);
    _toggleActionOnPress();
  }

  Future<void> _generateLapRegister() async {
    int lapMs;
    String speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training!.id!,
      duration: Duration(milliseconds: lapMs),
      lap: lapCounter(),
      split: _getSplit(),
      comments: 'PSCHistoryComments'.tr(args: [speed]),
    );

    await _historyManager.insert(history);
    _sendLapMessage(history.duration, speed, history.lap!);
    _toggleActionOnPress();
  }

  int _getSplit() {
    int split = splitCounter();
    return split == 0 ? bloc.splitCounterMax : split;
  }

  String _formatMs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 4);
  }

  void _sendStartedMessage() {
    final message = 'PSCStartedMessage'.tr(args: [
      athlete.name,
      DateFormat.Hms().format(_bloc.startTime),
    ]);
    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendSplitMessage(
    Duration time,
    String speed,
    int split,
  ) {
    final message = 'PSCSplitMessage'.tr(args: [
      athlete.name,
      split.toString(),
      _formatMs(time),
      speed,
    ]);

    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendLapMessage(
    Duration time,
    String speed,
    int lap,
  ) {
    final message = 'PSCLapMessage'.tr(args: [
      athlete.name,
      lap.toString(),
      _formatMs(time),
      speed,
    ]);

    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendFinishMessage() {
    final message = 'PSCFinishMessage'.tr(args: [
      athlete.name,
      DateFormat.Hms().format(DateTime.now()),
    ]);

    _stopwatchController.sendHistoryMessage(message);
  }

  (int, String) _calculateLapTimeSpeed() {
    final lapMS = bloc.lapDuration.inMilliseconds;

    final speed = StopwatchFunctions.speedCalc(
      length: training.lapLength,
      time: lapMS / 1000,
      training: training,
    );

    return (lapMS, speed);
  }

  (int, String) _calculateSplitTimeSpeed() {
    final splitMS = bloc.splitDuration.inMilliseconds;

    final speed = StopwatchFunctions.speedCalc(
      length: training.splitLength,
      time: splitMS / 1000,
      training: training,
    );
    return (splitMS, speed);
  }
}
