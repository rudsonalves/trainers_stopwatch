import 'dart:developer';

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

  void generateReport() async {
    final numberOfSplits = histories.length - 1;
    final totalLength = numberOfSplits * training.splitLength;
    final totalOfLaps = (totalLength / training.lapLength).round();
    final totalDuration =
        histories.fold(Duration.zero, (sum, item) => sum + item.duration);
    final mediumSpeed = StopwatchFunctions.speedCalc(
      length: totalLength,
      time: totalDuration.inMilliseconds / 1000,
      training: training,
    );

    log('          User: ${user.name}');
    log('          Date: ${DateFormat.yMd().add_Hms().format(training.date)}');
    log('  Total Length: ${totalLength.toStringAsFixed(1)} ${training.distanceUnit}:');
    log('    Total Time: ${StopwatchFunctions.formatDuration(totalDuration)}');
    log('  Medium Speed: $mediumSpeed');
    log('    Lap Length: ${training.lapLength} ${training.distanceUnit}');
    log('  Split Length: ${training.splitLength} ${training.distanceUnit}');
    log('Number of Laps: $totalOfLaps');
    log('-------------------------------------------');
    log('Split/Lap | time (s) | Speed (${training.speedUnit})');

    for (int index = 1; index < histories.length; index++) {
      final messages = createSplitLapMessages(
        index,
        histories[index],
      );

      log('${messages[0].title} ${messages[0].body}');
      if (messages.length == 1) continue;
      log('${messages[1].title} ${messages[1].body}');
    }
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

  // List<MessagesModel> nextMessage() {
  //   if (histories.length == 1) {
  //     return [startedMessage(histories.first)];
  //   }

  //   return createSplitLapMessages(
  //     histories.length,
  //     histories.last,
  //   );
  // }

  MessagesModel startedMessage(
    HistoryModel history,
  ) {
    String body;

    if (history.comments == null || history.comments!.isEmpty) {
      body = 'PSCStartedMessage'.tr(args: [
        DateFormat.yMd().add_Hms().format(training.date),
      ]);
    } else {
      body = 'PSCStartedMessage'.tr(args: [
        DateFormat.yMd().add_Hms().format(training.date),
      ]);
    }

    return MessagesModel(
      title: 'HPCTrainingStarting'.tr(),
      body: body,
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
    final String body;
    if (history.comments == null) {
      final speed = StopwatchFunctions.speedCalc(
        length: training.splitLength,
        time: history.duration.inMilliseconds / 1000,
        training: training,
      );
      body = 'PSCHistoryComments'.tr(args: [speed]);
    } else {
      body = history.comments!;
    }

    return MessagesModel(
      title: 'HPCSplitTime'.tr(args: [
        splitIndex.toString(),
        StopwatchFunctions.formatDuration(history.duration)
      ]),
      body: body,
      msgType: MessageType.isSplit,
      historyId: history.id!,
    );
  }

  MessagesModel lapMessage(
    int lapIndex,
    HistoryModel history,
  ) {
    final String body;

    final speed = StopwatchFunctions.speedCalc(
      length: training.lapLength,
      time: _lapDuration.inMilliseconds / 1000,
      training: training,
    );
    body = 'PSCHistoryComments'.tr(args: [speed]);

    return MessagesModel(
      title: 'HPCLapTime'.tr(args: [
        lapIndex.toString(),
        StopwatchFunctions.formatDuration(_lapDuration),
      ]),
      body: body,
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
