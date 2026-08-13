import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/units/speed_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/units/unit_compatibility.dart';

void main() {
  const expected = <DistanceUnit, Set<SpeedUnit>>{
    DistanceUnit.meter: {
      SpeedUnit.metersPerSecond,
      SpeedUnit.kilometersPerHour,
    },
    DistanceUnit.kilometer: {
      SpeedUnit.metersPerSecond,
      SpeedUnit.kilometersPerHour,
    },
    DistanceUnit.yard: {
      SpeedUnit.yardsPerSecond,
      SpeedUnit.metersPerSecond,
      SpeedUnit.milesPerHour,
    },
    DistanceUnit.mile: {
      SpeedUnit.yardsPerSecond,
      SpeedUnit.metersPerSecond,
      SpeedUnit.milesPerHour,
    },
  };

  test('preserves the current allowed unit matrix', () {
    for (final distanceUnit in DistanceUnit.values) {
      expect(distanceUnit.allowedSpeedUnits, expected[distanceUnit]);
    }
  });

  test('validates every distance and speed combination', () {
    for (final distanceUnit in DistanceUnit.values) {
      for (final speedUnit in SpeedUnit.values) {
        expect(
          distanceUnit.supports(speedUnit),
          expected[distanceUnit]!.contains(speedUnit),
          reason: '${distanceUnit.symbol} with ${speedUnit.symbol}',
        );
      }
    }
  });
}
