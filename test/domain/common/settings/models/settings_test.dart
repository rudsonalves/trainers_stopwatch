import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';

void main() {
  Distance distance(double value, DistanceUnit unit) =>
      Distance.create(value: value, unit: unit).value!;

  group('Settings', () {
    test('uses the current metric and application defaults', () {
      final result = Settings.create();
      final settings = result.value!;

      expect(settings.id, isNull);
      expect(settings.splitDistance.value, 200);
      expect(settings.splitDistance.unit, DistanceUnit.meter);
      expect(settings.lapDistance.value, 1000);
      expect(settings.lapDistance.unit, DistanceUnit.meter);
      expect(settings.brightness, BrightnessPreference.dark);
      expect(settings.contrast, ContrastPreference.standard);
      expect(settings.language, LanguagePreference.englishUnitedStates);
      expect(settings.refreshInterval, const Duration(milliseconds: 66));
    });

    test('rejects zero default distance', () {
      final result = Settings.create(
        splitDistance: distance(0, DistanceUnit.meter),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects different default distance units', () {
      final result = Settings.create(
        splitDistance: distance(200, DistanceUnit.meter),
        lapDistance: distance(1, DistanceUnit.kilometer),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('rejects a non-positive refresh interval', () {
      final result = Settings.create(refreshInterval: Duration.zero);

      expect(result.isFailure, isTrue);
      expect(result.error?.code, AppErrorCode.invalidData);
    });

    test('has value equality', () {
      final first = Settings.create(id: 1);
      final second = Settings.create(id: 1);

      expect(first.value, second.value);
      expect(first.value.hashCode, second.value.hashCode);
    });
  });
}
