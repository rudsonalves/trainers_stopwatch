import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/events/training_event.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';

void main() {
  final speed = Speed.create(
    value: 10,
    unit: SpeedUnit.metersPerSecond,
  ).value!;

  test('TrainingStarted carries no measurement or presentation data', () {
    const event = TrainingStarted(historyId: 1, comments: 'started');

    expect(event.historyId, 1);
    expect(event.comments, 'started');
  });

  group('SplitRecorded', () {
    test('carries a neutral measured split', () {
      final result = SplitRecorded.create(
        historyId: 2,
        comments: 'split',
        splitIndex: 1,
        duration: const Duration(seconds: 20),
        speed: speed,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.splitIndex, 1);
      expect(result.value?.duration, const Duration(seconds: 20));
      expect(result.value?.speed, speed);
    });

    test('rejects a non-positive index', () {
      final result = SplitRecorded.create(
        splitIndex: 0,
        duration: const Duration(seconds: 1),
        speed: speed,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });
  });

  group('LapRecorded', () {
    test('carries a neutral measured lap', () {
      final result = LapRecorded.create(
        historyId: 3,
        comments: 'lap',
        lapIndex: 2,
        duration: const Duration(seconds: 40),
        speed: speed,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.lapIndex, 2);
      expect(result.value?.duration, const Duration(seconds: 40));
      expect(result.value?.speed, speed);
    });

    test('rejects negative duration', () {
      final result = LapRecorded.create(
        lapIndex: 1,
        duration: const Duration(microseconds: -1),
        speed: speed,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });
  });

  test('measured events support value equality', () {
    final first = SplitRecorded.create(
      historyId: 2,
      comments: 'split',
      splitIndex: 1,
      duration: const Duration(seconds: 20),
      speed: speed,
    );
    final second = SplitRecorded.create(
      historyId: 2,
      comments: 'split',
      splitIndex: 1,
      duration: const Duration(seconds: 20),
      speed: speed,
    );

    expect(first.value, second.value);
    expect(first.value.hashCode, second.value.hashCode);
  });
}
