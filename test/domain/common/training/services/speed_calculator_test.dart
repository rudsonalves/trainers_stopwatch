import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/services/speed_calculator.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';

void main() {
  const calculator = SpeedCalculator();

  Distance distance(double value, [DistanceUnit unit = DistanceUnit.meter]) =>
      Distance.create(value: value, unit: unit).value!;

  group('SpeedCalculator', () {
    test('uses metric units by default', () {
      final result = calculator.calculate(
        distance: distance(200),
        duration: const Duration(seconds: 20),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.value, 10);
      expect(result.value?.unit, SpeedUnit.metersPerSecond);
    });

    test('preserves the current m/s calculation', () {
      final result = calculator.calculate(
        distance: distance(100, DistanceUnit.meter),
        duration: const Duration(seconds: 10),
        outputUnit: SpeedUnit.metersPerSecond,
      );

      expect(result.value?.value, closeTo(10, 1e-12));
    });

    test('preserves the current km/h calculation', () {
      final result = calculator.calculate(
        distance: distance(1, DistanceUnit.kilometer),
        duration: const Duration(seconds: 100),
        outputUnit: SpeedUnit.kilometersPerHour,
      );

      expect(result.value?.value, closeTo(36, 1e-12));
    });

    test('preserves the current yd/s calculation', () {
      final result = calculator.calculate(
        distance: distance(100, DistanceUnit.yard),
        duration: const Duration(seconds: 10),
        outputUnit: SpeedUnit.yardsPerSecond,
      );

      // Uses the same conversion factors as the current application.
      expect(result.value?.value, closeTo(9.99996984, 1e-8));
    });

    test('preserves the current mph calculation', () {
      final result = calculator.calculate(
        distance: distance(1, DistanceUnit.mile),
        duration: const Duration(hours: 1),
        outputUnit: SpeedUnit.milesPerHour,
      );

      // Uses the same conversion factors as the current application.
      expect(result.value?.value, closeTo(0.9999991721111111, 1e-12));
    });

    test('keeps microsecond precision without rounding', () {
      final result = calculator.calculate(
        distance: distance(1),
        duration: const Duration(microseconds: 500000),
      );

      expect(result.value?.value, 2);
    });

    test('allows zero distance and returns zero speed', () {
      final result = calculator.calculate(
        distance: distance(0),
        duration: const Duration(seconds: 1),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.value, 0);
    });

    test('rejects zero duration with its specific error', () {
      final result = calculator.calculate(
        distance: distance(100),
        duration: Duration.zero,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.zeroElapsedTime);
    });

    test('rejects negative duration as invalid data', () {
      final result = calculator.calculate(
        distance: distance(100),
        duration: const Duration(seconds: -1),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects an incompatible distance and speed unit', () {
      final result = calculator.calculate(
        distance: distance(100, DistanceUnit.meter),
        duration: const Duration(seconds: 10),
        outputUnit: SpeedUnit.milesPerHour,
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });
  });
}
