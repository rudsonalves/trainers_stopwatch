import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';

void main() {
  group('Distance', () {
    test('uses meters by default', () {
      final result = Distance.create(value: 200);

      expect(result.value?.value, 200);
      expect(result.value?.unit, DistanceUnit.meter);
      expect(result.value?.inMeters, 200);
    });

    test('allows zero as absence of displacement', () {
      final result = Distance.create(value: 0);

      expect(result.isSuccess, isTrue);
      expect(result.value?.inMeters, 0);
    });

    const cases = {
      DistanceUnit.meter: (input: 1.0, meters: 1.0),
      DistanceUnit.kilometer: (input: 1.0, meters: 1000.0),
      DistanceUnit.yard: (input: 1.0, meters: 0.9144),
      DistanceUnit.mile: (input: 1.0, meters: 1609.34),
    };

    for (final MapEntry(:key, :value) in cases.entries) {
      test('normalizes ${key.symbol} to meters without rounding', () {
        final result = Distance.create(value: value.input, unit: key);

        expect(result.value?.inMeters, closeTo(value.meters, 1e-12));
      });
    }

    for (final invalid in [
      -1.0,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      test('rejects invalid value $invalid', () {
        final result = Distance.create(value: invalid);

        expect(result.isFailure, isTrue);
        expect(result.error?.code, AppErrorCode.invalidData);
      });
    }

    test('has value equality', () {
      final first = Distance.create(value: 1, unit: DistanceUnit.kilometer);
      final second = Distance.create(value: 1, unit: DistanceUnit.kilometer);

      expect(first.value, second.value);
      expect(first.value.hashCode, second.value.hashCode);
    });
  });
}
