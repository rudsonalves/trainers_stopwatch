import '/core/result/result.dart';
import '../units/speed_unit.dart';

final class Speed {
  final double value;
  final SpeedUnit unit;

  const Speed._({required this.value, required this.unit});

  static Result<Speed> create({
    required double value,
    SpeedUnit unit = defaultSpeedUnit,
  }) {
    if (!value.isFinite || value < 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Speed must be finite and non-negative.',
          details: value,
        ),
      );
    }

    return Success(Speed._(value: value, unit: unit));
  }

  static Result<Speed> fromMetersPerSecond(
    double metersPerSecond, {
    SpeedUnit unit = defaultSpeedUnit,
  }) {
    if (!metersPerSecond.isFinite || metersPerSecond < 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Speed must be finite and non-negative.',
          details: metersPerSecond,
        ),
      );
    }

    return Success(
      Speed._(
        value: metersPerSecond * unit.fromMetersPerSecondFactor,
        unit: unit,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Speed && value == other.value && unit == other.unit;

  @override
  int get hashCode => Object.hash(value, unit);
}
