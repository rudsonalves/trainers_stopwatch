// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../bloc/stopwatch_bloc.dart';
import '../../../bloc/stopwatch_events.dart';
import '../../../bloc/stopwatch_state.dart';
import '../../../common/constants.dart';
import '../../../common/functions/stopwatch_functions.dart';
import '../../../common/functions/training_report.dart';
import '../../../common/models/messages_model.dart';
import '../../../common/singletons/app_settings.dart';
import '../../../manager/history_manager.dart';
import '../../../manager/training_manager.dart';
import '../../../common/models/user_model.dart';
import '../../../common/models/history_model.dart';
import '../../../common/models/training_model.dart';
import '../../stopwatch_page/stopwatch_page_controller.dart';

class PreciseStopwatchController {
  final _bloc = StopwatchBloc();
  final _trainingManager = TrainingManager();
  final _historyManager = HistoryManager();
  late final UserModel _user;
  TrainingModel? _training;
  bool isPaused = false;
  late double splitLength;
  late double lapLength;
  final _actionOnPress = ValueNotifier<bool>(false);
  bool _isCreatedTraining = false;

  final _stopwatchController = StopwatchPageController.instance;

  Color? lastColor;

  StopwatchBloc get bloc => _bloc;
  StopwatchState get state => _bloc.state;
  ValueNotifier<int> get lapCounter => _bloc.lapCounter;
  ValueNotifier<int> get splitCounter => _bloc.splitCounter;
  ValueNotifier<Duration> get durationTraining => _bloc.durationTraining;
  UserModel get user => _user;
  List<TrainingModel> get trainings => _trainingManager.trainings;
  List<HistoryModel> get histories => _historyManager.histories;
  TrainingModel get training => _training!;
  ValueNotifier<bool> get actionOnPress => _actionOnPress;
  late final int splitsPerLap;

  Future<void> init(UserModel user) async {
    _user = user;
    splitLength = AppSettings.instance.splitLength;
    lapLength = AppSettings.instance.lapLength;
    _bloc.splitCounterMax = lapLength ~/ splitLength;
    _trainingManager.init(_user.id!);
    _createNewTraining();
    splitsPerLap = (training.lapLength / training.splitLength).round();
  }

  void dispose() {
    _bloc.dispose();
    _actionOnPress.dispose();
  }

  Future<void> updateHistory(HistoryModel history) async {
    await _historyManager.update(history);
  }

  Future<void> deleteHistory(int historyId) async {
    await _historyManager.delete(historyId);
  }

  void _toggleActionOnPress() {
    _actionOnPress.value = !_actionOnPress.value;
  }

  void _createNewTraining() {
    _training = TrainingModel(
      userId: _user.id!,
      date: DateTime.now(),
      splitLength: splitLength,
      lapLength: lapLength,
    );

    _isCreatedTraining = true;
  }

  Future<void> _insertTraining() async {
    if (_training!.id != null) {
      throw Exception('Error!!!');
    }
    if (lastColor != null && _training!.color == primaryColor) {
      _training!.color = lastColor!;
    }
    _training!.date = bloc.startTime;
    await _trainingManager.insert(_training!);
    _historyManager.init(_training!.id!);
    lastColor = _training!.color;
  }

  void updateSplitLapLength() {
    if (splitLength != _training!.splitLength) {
      splitLength = _training!.splitLength;
    }
    if (lapLength != _training!.lapLength) {
      lapLength = _training!.lapLength;
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
      comments: 'PSCStartedMessage'.tr(args: [
        DateFormat.yMd().add_Hms().format(_bloc.startTime),
      ]),
    );

    await _historyManager.insert(history);
    _toggleActionOnPress();
    _sendStartedMessage(history.comments!);
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

    if (_bloc.maxLaps != null && _bloc.maxLaps == _bloc.lapCounter.value) {
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
    SpeedValue speed;
    (splitMs, speed) = _calculateSplitTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training!.id!,
      duration: Duration(milliseconds: splitMs),
      comments: 'PSCHistoryComments'.tr(args: [speed.toString()]),
    );

    final hIndex = TrainingReport.getIndex(histories.length - 1, splitsPerLap);
    await _historyManager.insert(history);
    _sendSplitMessage(history, hIndex.splitIndex, speed);
    _toggleActionOnPress();
  }

  Future<void> _generateLapRegister() async {
    int lapMs;
    SpeedValue speed;
    (lapMs, speed) = _calculateLapTimeSpeed();

    HistoryModel history = HistoryModel(
      trainingId: _training!.id!,
      duration: Duration(milliseconds: lapMs),
      comments: 'PSCHistoryComments'.tr(args: [speed.toString()]),
    );

    final hIndex = TrainingReport.getIndex(histories.length - 1, splitsPerLap);
    _sendLapMessage(history, hIndex.lapIndex, speed);
    _toggleActionOnPress();
  }

  void _sendStartedMessage(String comments) {
    final message = MessagesModel(
      userName: user.name,
      duration: Duration.zero,
      comments: comments,
      color: _training!.color,
      msgType: MessageType.isStarting,
    );
    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendSplitMessage(
    HistoryModel history,
    int split,
    SpeedValue speed,
  ) {
    final message = MessagesModel(
      userName: user.name,
      label: 'Split[$split]',
      speed: speed,
      duration: history.duration,
      comments: 'PSCSplitMessage'.tr(args: [
        split.toString(),
        StopwatchFunctions.formatDuration(history.duration),
        history.comments!,
      ]),
      color: _training!.color,
      msgType: MessageType.isSplit,
    );

    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendLapMessage(
    HistoryModel history,
    int lap,
    SpeedValue speed,
  ) {
    final message = MessagesModel(
      userName: user.name,
      label: 'Lap[$lap]',
      speed: speed,
      duration: history.duration,
      comments: 'PSCLapMessage'.tr(args: [
        lap.toString(),
        StopwatchFunctions.formatDuration(history.duration),
        history.comments!,
      ]),
      color: _training!.color,
      msgType: MessageType.isLap,
    );

    _stopwatchController.sendHistoryMessage(message);
  }

  void _sendFinishMessage() {
    final message = MessagesModel(
      userName: user.name,
      duration: Duration.zero,
      comments: 'PSCFinishMessage'.tr(args: [
        DateFormat.Hms().format(DateTime.now()),
      ]),
      color: _training!.color,
      msgType: MessageType.isFinish,
    );

    _stopwatchController.sendHistoryMessage(message);
  }

  (int, SpeedValue) _calculateLapTimeSpeed() {
    final lapMS = bloc.lapDuration.inMilliseconds;

    final speed = StopwatchFunctions.speedCalc(
      length: _training!.lapLength,
      time: lapMS / 1000,
      training: _training!,
    );

    return (lapMS, speed);
  }

  (int, SpeedValue) _calculateSplitTimeSpeed() {
    final splitMS = bloc.splitDuration.inMilliseconds;

    final speed = StopwatchFunctions.speedCalc(
      length: _training!.splitLength,
      time: splitMS / 1000,
      training: _training!,
    );
    return (splitMS, speed);
  }
}
