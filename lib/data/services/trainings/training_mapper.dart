import '/core/result/result.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/training/units/distance_unit.dart';
import '/domain/common/training/units/speed_unit.dart';
import '/domain/common/training/values/distance.dart';
import '../database/table_attributes.dart';

class TrainingMapper {
  const TrainingMapper();

  Result<Training> fromMap(Map<String, Object?> map) {
    try {
      final distanceUnit = DistanceUnit.fromSymbol(
        map[trainingDistanceUnit] as String,
      );
      if (distanceUnit.isFailure) return Failure(distanceUnit.error!);

      final speedUnit = SpeedUnit.fromSymbol(map[trainingSpeedUnit] as String);
      if (speedUnit.isFailure) return Failure(speedUnit.error!);

      final split = Distance.create(
        value: (map[trainingSplitLength] as num).toDouble(),
        unit: distanceUnit.value!,
      );
      if (split.isFailure) return Failure(split.error!);

      final lap = Distance.create(
        value: (map[trainingLapLength] as num).toDouble(),
        unit: distanceUnit.value!,
      );
      if (lap.isFailure) return Failure(lap.error!);

      return Training.create(
        id: map[trainingId] as int?,
        userId: map[trainingUserId] as int,
        date: DateTime.fromMillisecondsSinceEpoch(map[trainingDate] as int),
        comments: map[trainingComments] as String?,
        splitDistance: split.value!,
        lapDistance: lap.value!,
        maxLaps: map[trainingMaxlaps] as int?,
        speedUnit: speedUnit.value!,
      );
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Invalid persisted training data.',
          details: (error: error, stackTrace: stackTrace, data: map),
        ),
      );
    }
  }

  Map<String, Object?> toMap(Training training) => <String, Object?>{
        if (training.id != null) trainingId: training.id,
        trainingUserId: training.userId,
        trainingDate: training.date.millisecondsSinceEpoch,
        trainingComments: training.comments,
        trainingSplitLength: training.splitDistance.value,
        trainingLapLength: training.lapDistance.value,
        trainingMaxlaps: training.maxLaps,
        trainingDistanceUnit: training.splitDistance.unit.symbol,
        trainingSpeedUnit: training.speedUnit.symbol,
      };
}
