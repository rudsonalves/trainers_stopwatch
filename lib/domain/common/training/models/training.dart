import '/core/result/result.dart';
import '../units/speed_unit.dart';
import '../units/unit_compatibility.dart';
import '../values/distance.dart';

final class Training {
  static final defaultSplitDistance = Distance.create(value: 200).value!;
  static final defaultLapDistance = Distance.create(value: 1000).value!;

  final int? id;
  final int userId;
  final DateTime date;
  final String? comments;
  final Distance splitDistance;
  final Distance lapDistance;
  final int? maxLaps;
  final SpeedUnit speedUnit;

  const Training._({
    this.id,
    required this.userId,
    required this.date,
    this.comments,
    required this.splitDistance,
    required this.lapDistance,
    this.maxLaps,
    required this.speedUnit,
  });

  static Result<Training> create({
    int? id,
    required int userId,
    required DateTime date,
    String? comments,
    Distance? splitDistance,
    Distance? lapDistance,
    int? maxLaps,
    SpeedUnit speedUnit = defaultSpeedUnit,
  }) {
    final resolvedSplitDistance = splitDistance ?? defaultSplitDistance;
    final resolvedLapDistance = lapDistance ?? defaultLapDistance;

    if (userId <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Training requires a persisted user.',
          details: userId,
        ),
      );
    }

    if (maxLaps != null && maxLaps <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Maximum laps must be greater than zero.',
          details: maxLaps,
        ),
      );
    }

    if (resolvedSplitDistance.value == 0 || resolvedLapDistance.value == 0) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Training distances must be greater than zero.',
        ),
      );
    }

    if (resolvedSplitDistance.unit != resolvedLapDistance.unit) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Split and lap distances must use the same unit.',
        ),
      );
    }

    if (!resolvedSplitDistance.unit.supports(speedUnit)) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Incompatible training distance and speed units.',
          details: (
            distanceUnit: resolvedSplitDistance.unit,
            speedUnit: speedUnit,
          ),
        ),
      );
    }

    return Success(
      Training._(
        id: id,
        userId: userId,
        date: date,
        comments: comments,
        splitDistance: resolvedSplitDistance,
        lapDistance: resolvedLapDistance,
        maxLaps: maxLaps,
        speedUnit: speedUnit,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Training &&
          id == other.id &&
          userId == other.userId &&
          date == other.date &&
          comments == other.comments &&
          splitDistance == other.splitDistance &&
          lapDistance == other.lapDistance &&
          maxLaps == other.maxLaps &&
          speedUnit == other.speedUnit;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        date,
        comments,
        splitDistance,
        lapDistance,
        maxLaps,
        speedUnit,
      );
}
