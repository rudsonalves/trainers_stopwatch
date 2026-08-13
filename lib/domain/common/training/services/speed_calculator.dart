import '/core/result/result.dart';
import '../units/speed_unit.dart';
import '../units/unit_compatibility.dart';
import '../values/distance.dart';
import '../values/speed.dart';

final class SpeedCalculator {
  const SpeedCalculator();

  Result<Speed> calculate({
    required Distance distance,
    required Duration duration,
    SpeedUnit outputUnit = defaultSpeedUnit,
  }) {
    if (duration == Duration.zero) {
      return const Failure(
        AppError(
          code: AppErrorCode.zeroElapsedTime,
          message: 'Elapsed time must be greater than zero.',
        ),
      );
    }

    if (duration.isNegative) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Elapsed time cannot be negative.',
          details: duration,
        ),
      );
    }

    if (!distance.unit.supports(outputUnit)) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Incompatible distance and speed units.',
          details: (
            distanceUnit: distance.unit,
            speedUnit: outputUnit,
          ),
        ),
      );
    }

    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    final metersPerSecond = distance.inMeters / seconds;

    if (!metersPerSecond.isFinite) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Speed calculation produced a non-finite value.',
          details: metersPerSecond,
        ),
      );
    }

    return Speed.fromMetersPerSecond(metersPerSecond, unit: outputUnit);
  }
}
