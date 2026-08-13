import 'package:flutter/material.dart';

import '../../domain/common/training/events/training_event.dart';
import '../functions/stopwatch_functions.dart';
import '../models/messages_model.dart';

final class TrainingEventMessageMapper {
  const TrainingEventMessageMapper();

  MessagesModel map({
    required TrainingEvent event,
    required String userName,
    required Color color,
    required String startedLabel,
  }) {
    return switch (event) {
      TrainingStarted() => MessagesModel(
          userName: userName,
          label: startedLabel,
          duration: Duration.zero,
          comments: event.comments ?? '',
          color: color,
          msgType: MessageType.isStarting,
          historyId: event.historyId ?? 0,
        ),
      SplitRecorded() => MessagesModel(
          userName: userName,
          label: 'Split[${event.splitIndex}]',
          speed: SpeedValue(event.speed.value, event.speed.unit.symbol),
          duration: event.duration,
          comments: event.comments ?? '',
          color: color,
          msgType: MessageType.isSplit,
          historyId: event.historyId ?? 0,
        ),
      LapRecorded() => MessagesModel(
          userName: userName,
          label: 'Lap[${event.lapIndex}]',
          speed: SpeedValue(event.speed.value, event.speed.unit.symbol),
          duration: event.duration,
          comments: event.comments ?? '',
          color: color,
          msgType: MessageType.isLap,
          historyId: event.historyId ?? 0,
        ),
    };
  }
}
