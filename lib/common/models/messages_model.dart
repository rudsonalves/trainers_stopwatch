import 'package:flutter/material.dart';

import '../constants.dart';
import '../functions/stopwatch_functions.dart';

enum MessageType {
  isLap,
  isSplit,
  isStarting,
  isFinish,
}

class MessagesModel {
  String userName;
  String label;
  SpeedValue speed;
  Duration duration;
  String comments;
  int historyId;
  Color color;
  MessageType msgType;

  MessagesModel({
    this.userName = '',
    this.label = '',
    this.speed = const SpeedValue(),
    this.duration = Duration.zero,
    this.comments = '',
    this.color = primaryColor,
    this.msgType = MessageType.isSplit,
    this.historyId = 0,
  });

  @override
  String toString() => 'MessagesModel(title: "$title",'
      ' historyId: $historyId,'
      ' subTitle: "$subTitle",'
      ' body: "$comments"'
      ')';

  bool get isNotEmpty =>
      label.isNotEmpty || speed.value != 0 || comments.isNotEmpty;

  String get title =>
      '$label time: ${StopwatchFunctions.formatDuration(duration)}';

  String get subTitle {
    switch (msgType) {
      case MessageType.isLap:
        return 'Speed: $speedString';
      // case MessageType.isSplit:
      //   return 'Speed: $speedString';
      case MessageType.isStarting:
        return comments;
      case MessageType.isFinish:
        return comments;
      default:
        return comments;
    }
  }

  String get logTitle => userName;

  String get logSubtitle {
    switch (msgType) {
      case MessageType.isLap:
        return '$label time: ${StopwatchFunctions.formatDuration(duration)} Speed: $speedString';
      case MessageType.isSplit:
        return '$label time: ${StopwatchFunctions.formatDuration(duration)} Speed: $speedString';
      case MessageType.isStarting:
        return comments;
      case MessageType.isFinish:
        return comments;
    }
  }

  String get speedString =>
      '${speed.value.toStringAsFixed(2)} ${speed.speedUnit}';
}
