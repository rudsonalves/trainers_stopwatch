import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/models/messages_model.dart';
import 'package:trainers_stopwatch/common/presentation/training_event_message_mapper.dart';
import 'package:trainers_stopwatch/domain/common/training/events/training_event.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';

void main() {
  const mapper = TrainingEventMessageMapper();
  const userName = 'Ana';
  const color = Colors.indigo;
  const startedLabel = 'Training started';
  final speed = Speed.create(
    value: 10.126,
    unit: SpeedUnit.metersPerSecond,
  ).value!;

  MessagesModel map(TrainingEvent event) => mapper.map(
        event: event,
        userName: userName,
        color: color,
        startedLabel: startedLabel,
      );

  test('maps a start event using the localized label supplied by the caller',
      () {
    const event = TrainingStarted(historyId: 1, comments: 'started');

    final message = map(event);

    expect(message.userName, userName);
    expect(message.label, startedLabel);
    expect(message.duration, Duration.zero);
    expect(message.comments, 'started');
    expect(message.color, color);
    expect(message.msgType, MessageType.isStarting);
    expect(message.historyId, 1);
  });

  test('maps a split event with its presentation label', () {
    final event = SplitRecorded.create(
      historyId: 2,
      comments: 'split',
      splitIndex: 3,
      duration: const Duration(seconds: 20),
      speed: speed,
    ).value!;

    final message = map(event);

    expect(message.label, 'Split[3]');
    expect(message.speed.value, 10.126);
    expect(message.speed.speedUnit, 'm/s');
    expect(message.speedString, '10.13 m/s');
    expect(message.msgType, MessageType.isSplit);
  });

  test('maps a lap event with accumulated duration and its label', () {
    final event = LapRecorded.create(
      historyId: 6,
      comments: 'lap',
      lapIndex: 2,
      duration: const Duration(seconds: 100),
      speed: speed,
    ).value!;

    final message = map(event);

    expect(message.label, 'Lap[2]');
    expect(message.duration, const Duration(seconds: 100));
    expect(message.msgType, MessageType.isLap);
  });
}
