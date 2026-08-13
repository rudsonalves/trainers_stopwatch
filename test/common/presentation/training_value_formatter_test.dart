import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/functions/stopwatch_functions.dart';
import 'package:trainers_stopwatch/common/presentation/training_value_formatter.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';

void main() {
  group('TrainingValueFormatter', () {
    const durationCases = [
      (duration: Duration(milliseconds: 1234), formatted: '1.23 s'),
      (
        duration: Duration(minutes: 1, milliseconds: 2500),
        formatted: '01:2.50 s',
      ),
      (
        duration: Duration(hours: 1, minutes: 2, milliseconds: 3450),
        formatted: '01:62:3843.45 s',
      ),
    ];

    for (final (:duration, :formatted) in durationCases) {
      test('formats $duration as $formatted', () {
        expect(TrainingValueFormatter.formatDuration(duration), formatted);
      });

      test('keeps StopwatchFunctions compatibility for $duration', () {
        expect(StopwatchFunctions.formatDuration(duration), formatted);
      });
    }

    test('rounds speed only at the presentation boundary', () {
      final speed = Speed.create(
        value: 3.14159,
        unit: SpeedUnit.metersPerSecond,
      ).value!;

      expect(TrainingValueFormatter.formatSpeed(speed), '3.14 m/s');
      expect(speed.value, 3.14159);
    });
  });
}
