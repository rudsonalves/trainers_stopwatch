import 'distance_unit.dart';
import 'speed_unit.dart';

extension DistanceUnitCompatibility on DistanceUnit {
  Set<SpeedUnit> get allowedSpeedUnits => switch (this) {
        DistanceUnit.meter || DistanceUnit.kilometer => const {
            SpeedUnit.metersPerSecond,
            SpeedUnit.kilometersPerHour,
          },
        DistanceUnit.yard || DistanceUnit.mile => const {
            SpeedUnit.yardsPerSecond,
            SpeedUnit.metersPerSecond,
            SpeedUnit.milesPerHour,
          },
      };

  bool supports(SpeedUnit speedUnit) => allowedSpeedUnits.contains(speedUnit);
}
