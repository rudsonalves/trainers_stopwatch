import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';

void main() {
  test('uses meter as the default distance unit', () {
    expect(defaultDistanceUnit, DistanceUnit.meter);
  });

  group('DistanceUnit persistence symbol', () {
    const cases = {
      'm': DistanceUnit.meter,
      'km': DistanceUnit.kilometer,
      'yd': DistanceUnit.yard,
      'mi': DistanceUnit.mile,
    };

    for (final MapEntry(:key, :value) in cases.entries) {
      test('parses and serializes $key', () {
        final result = DistanceUnit.fromSymbol(key);

        expect(result.isSuccess, isTrue);
        expect(result.value, value);
        expect(result.value?.symbol, key);
      });
    }

    test('rejects an unknown symbol without applying a default', () {
      final result = DistanceUnit.fromSymbol('meters');

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
      expect(result.error?.details, 'meters');
    });
  });
}
