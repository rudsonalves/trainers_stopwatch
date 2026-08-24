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

import '/application/stopwatch/bloc/stopwatch_bloc.dart';
import '/application/stopwatch/bloc/stopwatch_event.dart';
import '/application/stopwatch/bloc/stopwatch_state.dart';
import '/common/adapters/training_domain_adapter.dart';
import '/common/constants.dart';
import '/common/functions/stopwatch_functions.dart';
import '/common/functions/training_report.dart';
import '/common/models/history_model.dart';
import '/common/models/messages_model.dart';
import '/common/models/training_model.dart';
import '/common/models/user_model.dart';
import '/common/singletons/app_settings.dart';
import '/domain/common/stopwatch/models/stopwatch_snapshot.dart';
import '/domain/usecases/trainings/create_training_use_case.dart';
import '/manager/history_manager.dart';
import '/manager/training_manager.dart';
import '../../stopwatch_page/stopwatch_page_controller.dart';

class PreciseStopwatchController {
  final _bloc = StopwatchBloc();
  final TrainingManager _trainingManager;
  final HistoryManager _historyManager;
  final CreateTrainingUseCase _createTrainingUseCase;
  final StopwatchPageController _stopwatchController;
  late final UserModel _user;
  TrainingModel? _training;
  bool isPaused = false;
  late double splitLength;
  late double lapLength;
  final _actionOnPress = ValueNotifier<bool>(false);
  bool _isCreatedTraining = false;

  PreciseStopwatchController({
    required TrainingManager trainingManager,
    required HistoryManager historyManager,
    required CreateTrainingUseCase createTrainingUseCase,
    required StopwatchPageController stopwatchController,
  })  : _trainingManager = trainingManager,
        _historyManager = historyManager,
        _createTrainingUseCase = createTrainingUseCase,
        _stopwatchController = stopwatchController;

  Color? lastColor;

  StopwatchBloc get bloc => _bloc;
  StopwatchState get state => _bloc.state;
  UserModel get user => _user;
  List<TrainingModel> get trainings => _trainingManager.trainings;
  List<HistoryModel> get histories => _historyManager.histories;
  TrainingModel get training => _training!;
  ValueNotifier<bool> get actionOnPress => _actionOnPress;
  late final int splitsPerLap;

  Future<void> init(UserModel user) async {
    _user = user;
    // Legacy settings bridge; remove with stopwatch migration in backlog 007.
    splitLength = AppSettings.instance.splitLength;
    lapLength = AppSettings.instance.lapLength;
    _configureBloc();
    await _trainingManager.init(_user.id!);
    _createNewTraining();
    splitsPerLap = (training.lapLength / training.splitLength).round();
  }

  void dispose() {
    _bloc.close();
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

  Future<void> _insertTraining(String initialComments) async {
    if (_training!.id != null) {
      throw Exception('Error!!!');
    }
    if (lastColor != null && _training!.color == primaryColor) {
      _training!.color = lastColor!;
    }
    _training!.date = bloc.state.startedAt!;
    final domainTraining = _training!.toDomain();
    if (domainTraining.isFailure) throw domainTraining.error!;

    final initialization = await _createTrainingUseCase.execute(
      training: domainTraining.value!,
      initialComments: initialComments,
    );
    if (initialization.isFailure) throw initialization.error!;

    final initialized = initialization.value!;
    _training!.id = initialized.training.id;
    _historyManager.init(initialized.training.id!);
    lastColor = _training!.color;
  }

  void updateSplitLapLength() {
    if (splitLength != _training!.splitLength) {
      splitLength = _training!.splitLength;
    }
    if (lapLength != _training!.lapLength) {
      lapLength = _training!.lapLength;
    }

    _configureBloc();
  }

  void _configureBloc() {
    _bloc.add(
      StopwatchEventConfigure(
        maxLaps: _training?.maxlaps,
        splitsPerLap: lapLength ~/ splitLength,
      ),
    );
  }

  Future<void> blocStartTimer() async {
    if (_bloc.state.status == StopwatchStatus.paused) {
      await _dispatchAndWait(
        const StopwatchEventResume(),
        (state) => state.status == StopwatchStatus.running,
      );
      isPaused = false;
      return;
    }

    final state = await _dispatchAndWait(
      const StopwatchEventRun(),
      (state) => state.status == StopwatchStatus.running,
    );

    if (!_isCreatedTraining) {
      _createNewTraining();
    }
    final startedComments = 'PSCStartedMessage'.tr(args: [
      DateFormat.yMd().add_Hms().format(state.startedAt!),
    ]);
    await _insertTraining(startedComments);
    _toggleActionOnPress();
    _sendStartedMessage(startedComments);
  }

  Future<void> blocPauseTimer() async {
    await _dispatchAndWait(
      const StopwatchEventPause(),
      (state) => state.status == StopwatchStatus.paused,
    );
    isPaused = true;
  }

  Future<void> blocResetTimer() async {
    await _dispatchAndWait(
      const StopwatchEventReset(),
      (state) => state.status == StopwatchStatus.idle,
    );
    _toggleActionOnPress();
  }

  Future<void> blocLapTimer() async {
    final revision = _bloc.state.snapshotRevision;
    final state = await _dispatchAndWait(
      const StopwatchEventLap(),
      (state) => state.snapshotRevision > revision,
    );
    final snapshot = state.snapshot! as LapSnapshot;

    await _generateSplitRegister(snapshot.splitDuration);
    await _generateLapRegister(snapshot.lapDuration);

    if (_bloc.state.status == StopwatchStatus.finished) {
      isPaused = false;
      _isCreatedTraining = false;
      _sendFinishMessage();
      _toggleActionOnPress();
      _createNewTraining();
    }
  }

  Future<void> blocSplitTimer() async {
    final revision = _bloc.state.snapshotRevision;
    final state = await _dispatchAndWait(
      const StopwatchEventSplit(),
      (state) => state.snapshotRevision > revision,
    );
    final snapshot = state.snapshot! as SplitSnapshot;

    await _generateSplitRegister(snapshot.splitDuration);
  }

  Future<void> blocStopTimer() async {
    final revision = _bloc.state.snapshotRevision;
    final state = await _dispatchAndWait(
      const StopwatchEventStop(),
      (state) =>
          state.status == StopwatchStatus.finished &&
          state.snapshotRevision > revision,
    );
    final snapshot = state.snapshot! as FinishSnapshot;

    isPaused = false;
    _isCreatedTraining = false;

    await _generateSplitRegister(snapshot.finalSplitDuration);
    await _generateLapRegister(snapshot.finalLapDuration);

    _sendFinishMessage();
    _toggleActionOnPress();
    _createNewTraining();
  }

  Future<StopwatchState> _dispatchAndWait(
    StopwatchEvent event,
    bool Function(StopwatchState state) matches,
  ) {
    final nextState = _bloc.stream.firstWhere(matches);
    _bloc.add(event);
    return nextState;
  }

  Future<void> _generateSplitRegister(Duration duration) async {
    int splitMs;
    SpeedValue speed;
    (splitMs, speed) = _calculateSplitTimeSpeed(duration);

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

  Future<void> _generateLapRegister(Duration duration) async {
    int lapMs;
    SpeedValue speed;
    (lapMs, speed) = _calculateLapTimeSpeed(duration);

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

  (int, SpeedValue) _calculateLapTimeSpeed(Duration duration) {
    final lapMS = duration.inMilliseconds;

    final speed = StopwatchFunctions.speedCalc(
      length: _training!.lapLength,
      time: lapMS / 1000,
      training: _training!,
    );

    return (lapMS, speed);
  }

  (int, SpeedValue) _calculateSplitTimeSpeed(Duration duration) {
    final splitMS = duration.inMilliseconds;

    final speed = StopwatchFunctions.speedCalc(
      length: _training!.splitLength,
      time: splitMS / 1000,
      training: _training!,
    );
    return (splitMS, speed);
  }
}
