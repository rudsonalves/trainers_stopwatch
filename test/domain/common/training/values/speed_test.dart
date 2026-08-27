import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';

void main() {
  group('Speed', () {
    test('uses meters per second by default', () {
      final result = Speed.create(value: 10);

      expect(result.value?.value, 10);
      expect(result.value?.unit, SpeedUnit.metersPerSecond);
    });

    test('allows zero speed', () {
      final result = Speed.create(value: 0);

      expect(result.isSuccess, isTrue);
      expect(result.value?.value, 0);
    });

    const cases = {
      SpeedUnit.metersPerSecond: 1.0,
      SpeedUnit.kilometersPerHour: 3.6,
      SpeedUnit.yardsPerSecond: 1.09361,
      SpeedUnit.milesPerHour: 2.23694,
    };

    for (final MapEntry(:key, :value) in cases.entries) {
      test('converts m/s to ${key.symbol} without rounding', () {
        final result = Speed.fromMetersPerSecond(1, unit: key);

        expect(result.value?.value, closeTo(value, 1e-12));
        expect(result.value?.unit, key);
      });
    }

    for (final invalid in [
      -1.0,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      test('rejects invalid value $invalid', () {
        final direct = Speed.create(value: invalid);
        final converted = Speed.fromMetersPerSecond(invalid);

        expect(direct.isFailure, isTrue);
        expect(direct.error?.code, AppErrorCode.invalidData);
        expect(converted.isFailure, isTrue);
        expect(converted.error?.code, AppErrorCode.invalidData);
      });
    }

    test('has value equality', () {
      final first = Speed.create(value: 3.6, unit: SpeedUnit.kilometersPerHour);
      final second =
          Speed.create(value: 3.6, unit: SpeedUnit.kilometersPerHour);

      expect(first.value, second.value);
      expect(first.value.hashCode, second.value.hashCode);
    });
  });
}
