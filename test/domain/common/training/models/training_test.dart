import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';

void main() {
  Distance distance(double value, DistanceUnit unit) =>
      Distance.create(value: value, unit: unit).value!;

  group('Training', () {
    test('uses metric defaults and supports an entity not persisted yet', () {
      final result = Training.create(userId: 1, date: DateTime(2026));
      final training = result.value!;

      expect(training.id, isNull);
      expect(training.splitDistance.value, 200);
      expect(training.splitDistance.unit, DistanceUnit.meter);
      expect(training.lapDistance.value, 1000);
      expect(training.lapDistance.unit, DistanceUnit.meter);
      expect(training.speedUnit, SpeedUnit.metersPerSecond);
    });

    test('rejects a user that is not persisted', () {
      final result = Training.create(userId: 0, date: DateTime(2026));

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects non-positive maximum laps', () {
      final result = Training.create(
        userId: 1,
        date: DateTime(2026),
        maxLaps: 0,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects zero training distance', () {
      final result = Training.create(
        userId: 1,
        date: DateTime(2026),
        splitDistance: distance(0, DistanceUnit.meter),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects different split and lap units', () {
      final result = Training.create(
        userId: 1,
        date: DateTime(2026),
        splitDistance: distance(200, DistanceUnit.meter),
        lapDistance: distance(1, DistanceUnit.kilometer),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects an incompatible speed unit', () {
      final result = Training.create(
        userId: 1,
        date: DateTime(2026),
        speedUnit: SpeedUnit.milesPerHour,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('has value equality', () {
      final date = DateTime(2026);
      final first = Training.create(userId: 1, date: date).value!;
      final second = Training.create(userId: 1, date: date).value!;

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
