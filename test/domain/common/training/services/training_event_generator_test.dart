import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/training/events/training_event.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/services/training_event_generator.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';

void main() {
  const generator = TrainingEventGenerator();

  Distance distance(double value) =>
      Distance.create(value: value, unit: DistanceUnit.meter).value!;

  Training training({
    int? id = 10,
    double splitLength = 200,
    double lapLength = 1000,
  }) =>
      Training.create(
        id: id,
        userId: 1,
        date: DateTime(2026),
        splitDistance: distance(splitLength),
        lapDistance: distance(lapLength),
      ).value!;

  HistoryEntry history({
    required int id,
    int trainingId = 10,
    required Duration duration,
    String? comments,
  }) =>
      HistoryEntry.create(
        id: id,
        trainingId: trainingId,
        duration: duration,
        comments: comments,
      ).value!;

  List<HistoryEntry> historiesWithSplits(List<Duration> durations) => [
        history(id: 1, duration: Duration.zero, comments: 'started'),
        for (var index = 0; index < durations.length; index++)
          history(
            id: index + 2,
            duration: durations[index],
            comments: 'entry ${index + 1}',
          ),
      ];

  group('TrainingEventGenerator', () {
    test('returns an empty immutable event list for empty history', () {
      final result = generator.generate(training: training(), histories: []);

      expect(result.isSuccess, isTrue);
      expect(result.value, isEmpty);
      expect(() => result.value!.add(const TrainingStarted()),
          throwsUnsupportedError);
    });

    test('maps the first history to a start event without calculating speed',
        () {
      final result = generator.generate(
        training: training(),
        histories: historiesWithSplits([]),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value, [
        const TrainingStarted(historyId: 1, comments: 'started'),
      ]);
    });

    test('creates ordered splits for an incomplete lap', () {
      final result = generator.generate(
        training: training(),
        histories: historiesWithSplits([
          const Duration(seconds: 20),
          const Duration(seconds: 21),
        ]),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value, hasLength(3));
      expect(result.value![0], isA<TrainingStarted>());
      expect((result.value![1] as SplitRecorded).splitIndex, 1);
      expect((result.value![2] as SplitRecorded).splitIndex, 2);
      expect(result.value!.whereType<LapRecorded>(), isEmpty);
    });

    test('creates a lap after the fifth 200 meter split', () {
      final result = generator.generate(
        training: training(),
        histories:
            historiesWithSplits(List.filled(5, const Duration(seconds: 20))),
      );

      final events = result.value!;
      expect(events, hasLength(7));
      expect(events.whereType<SplitRecorded>().map((event) => event.splitIndex),
          [1, 2, 3, 4, 5]);
      final lap = events.last as LapRecorded;
      expect(lap.lapIndex, 1);
      expect(lap.duration, const Duration(seconds: 100));
      expect(lap.speed.value, closeTo(10, 1e-12));
    });

    test('resets accumulated lap duration across multiple laps', () {
      final durations = [
        ...List.filled(5, const Duration(seconds: 10)),
        ...List.filled(5, const Duration(seconds: 20)),
      ];
      final result = generator.generate(
        training: training(),
        histories: historiesWithSplits(durations),
      );

      final laps = result.value!.whereType<LapRecorded>().toList();
      expect(laps.map((lap) => lap.lapIndex), [1, 2]);
      expect(laps[0].duration, const Duration(seconds: 50));
      expect(laps[1].duration, const Duration(seconds: 100));
    });

    test('does not accumulate state between repeated calls', () {
      final histories =
          historiesWithSplits(List.filled(5, const Duration(seconds: 20)));

      final first =
          generator.generate(training: training(), histories: histories);
      final second =
          generator.generate(training: training(), histories: histories);

      expect(second.value, first.value);
    });

    test('propagates zeroElapsedTime for a zero duration split', () {
      final result = generator.generate(
        training: training(),
        histories: historiesWithSplits([Duration.zero]),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.zeroElapsedTime);
    });

    test('rejects a training without persistence identity when history exists',
        () {
      final result = generator.generate(
        training: training(id: null),
        histories: historiesWithSplits([]),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects history from a different training', () {
      final result = generator.generate(
        training: training(),
        histories: [history(id: 1, trainingId: 99, duration: Duration.zero)],
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('preserves rounding when lap is not a whole number of splits', () {
      final result = generator.generate(
        training: training(splitLength: 300, lapLength: 1000),
        histories: historiesWithSplits(
          List.filled(3, const Duration(seconds: 20)),
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.whereType<SplitRecorded>(), hasLength(3));
      expect(result.value!.whereType<LapRecorded>(), hasLength(1));
    });
  });
}
