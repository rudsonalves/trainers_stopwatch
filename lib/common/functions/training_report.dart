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

import '../models/history_model.dart';
import '../models/messages_model.dart';
import '../models/training_model.dart';
import '../models/user_model.dart';
import 'stopwatch_functions.dart';

class HistoryIndex {
  final bool isLap;
  final int lapIndex;
  final int splitIndex;

  HistoryIndex({
    required this.isLap,
    required this.lapIndex,
    required this.splitIndex,
  });
}

class TrainingReport {
  final UserModel user;
  final TrainingModel training;
  final List<HistoryModel> histories;
  late final int splitsPerLap;

  Duration _lapDuration = Duration.zero;
  final List<MessagesModel> _messages = [];

  List<MessagesModel> get messages => _messages;

  TrainingReport({
    required this.user,
    required this.training,
    required this.histories,
  }) {
    splitsPerLap = (training.lapLength / training.splitLength).round();
  }

  void createMessages() {
    _messages.clear();

    for (int index = 0; index < histories.length; index++) {
      List<MessagesModel> msgs = [];
      if (index == 0) {
        msgs = [startedMessage(histories.first)];
      } else {
        msgs = createSplitLapMessages(
          index,
          histories[index],
        );
      }
      _messages.addAll(msgs);
    }
  }

  MessagesModel startedMessage(
    HistoryModel history,
  ) {
    return MessagesModel(
      userName: user.name,
      label: 'HPCTrainingStarting'.tr(),
      comments: history.comments ?? '',
      duration: Duration.zero,
      msgType: MessageType.isStarting,
      historyId: history.id!,
    );
  }

  List<MessagesModel> createSplitLapMessages(
    int index,
    HistoryModel history,
  ) {
    List<MessagesModel> messages = [];
    final hIndex = getIndex(index, splitsPerLap);

    _lapDuration += history.duration;
    final msg = splitMessage(hIndex.splitIndex, history);
    messages.add(msg);

    if (hIndex.isLap) {
      final msg = lapMessage(hIndex.lapIndex, history);
      messages.add(msg);
      _lapDuration = Duration.zero;
    }

    return messages;
  }

  MessagesModel splitMessage(
    int splitIndex,
    HistoryModel history,
  ) {
    final speed = StopwatchFunctions.speedCalc(
      length: training.splitLength,
      time: history.duration.inMilliseconds / 1000,
      training: training,
    );

    return MessagesModel(
      userName: user.name,
      label: 'Split[$splitIndex]',
      speed: speed,
      duration: history.duration,
      comments: history.comments ?? '',
      msgType: MessageType.isSplit,
      historyId: history.id!,
    );
  }

  MessagesModel lapMessage(
    int lapIndex,
    HistoryModel history,
  ) {
    final speed = StopwatchFunctions.speedCalc(
      length: training.lapLength,
      time: _lapDuration.inMilliseconds / 1000,
      training: training,
    );

    return MessagesModel(
      userName: user.name,
      label: 'Lap[$lapIndex]',
      speed: speed,
      duration: history.duration,
      comments: history.comments ?? '',
      msgType: MessageType.isLap,
      historyId: history.id!,
    );
  }

  static HistoryIndex getIndex(int index, int splitsPerLap) {
    if (index < 0) {
      return HistoryIndex(
        isLap: false,
        lapIndex: 0,
        splitIndex: 0,
      );
    }

    final int lapIndex = index ~/ splitsPerLap;
    int splitIndex = index % splitsPerLap;
    splitIndex = splitIndex == 0 ? splitsPerLap : splitIndex;

    return HistoryIndex(
      isLap: splitIndex == splitsPerLap && lapIndex != 0,
      lapIndex: lapIndex,
      splitIndex: splitIndex,
    );
  }
}
