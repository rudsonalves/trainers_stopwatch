import '/core/result/result.dart';
import '../units/distance_unit.dart';

class Distance {
  final double value;
  final DistanceUnit unit;

  const Distance._({required this.value, required this.unit});

  static Result<Distance> create({
    required double value,
    DistanceUnit unit = defaultDistanceUnit,
  }) {
    if (!value.isFinite || value < 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Distance must be finite and non-negative.',
          details: value,
        ),
      );
    }

    return Success(Distance._(value: value, unit: unit));
  }

  double get inMeters => value * unit.metersFactor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Distance && value == other.value && unit == other.unit;

  @override
  int get hashCode => Object.hash(value, unit);
}
