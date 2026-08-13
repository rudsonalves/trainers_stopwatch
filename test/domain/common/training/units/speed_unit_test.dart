import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';

void main() {
  test('uses meters per second as the default speed unit', () {
    expect(defaultSpeedUnit, SpeedUnit.metersPerSecond);
  });

  group('SpeedUnit persistence symbol', () {
    const cases = {
      'm/s': SpeedUnit.metersPerSecond,
      'km/h': SpeedUnit.kilometersPerHour,
      'yd/s': SpeedUnit.yardsPerSecond,
      'mph': SpeedUnit.milesPerHour,
    };

    for (final MapEntry(:key, :value) in cases.entries) {
      test('parses and serializes $key', () {
        final result = SpeedUnit.fromSymbol(key);

        expect(result.isSuccess, isTrue);
        expect(result.value, value);
        expect(result.value?.symbol, key);
      });
    }

    test('rejects an unknown symbol without applying a default', () {
      final result = SpeedUnit.fromSymbol('kph');

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
      expect(result.error?.details, 'kph');
    });
  });
}
