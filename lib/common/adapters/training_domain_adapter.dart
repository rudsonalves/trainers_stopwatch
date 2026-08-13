import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/common/training/models/training.dart';
import '../../domain/common/training/units/distance_unit.dart';
import '../../domain/common/training/units/speed_unit.dart';
import '../../domain/common/training/values/distance.dart';
import '../constants.dart';
import '../models/training_model.dart';

// Temporary legacy bridge. Remove with the training migration in backlog 006.
extension TrainingModelDomainAdapter on TrainingModel {
  Result<Training> toDomain() {
    final parsedDistanceUnit = DistanceUnit.fromSymbol(distanceUnit);
    if (parsedDistanceUnit.isFailure) {
      return Failure(parsedDistanceUnit.error!);
    }

    final parsedSpeedUnit = SpeedUnit.fromSymbol(speedUnit);
    if (parsedSpeedUnit.isFailure) return Failure(parsedSpeedUnit.error!);

    final split = Distance.create(
      value: splitLength,
      unit: parsedDistanceUnit.value!,
    );
    if (split.isFailure) return Failure(split.error!);

    final lap = Distance.create(
      value: lapLength,
      unit: parsedDistanceUnit.value!,
    );
    if (lap.isFailure) return Failure(lap.error!);

    return Training.create(
      id: id,
      userId: userId,
      date: date,
      comments: comments,
      splitDistance: split.value!,
      lapDistance: lap.value!,
      maxLaps: maxlaps,
      speedUnit: parsedSpeedUnit.value!,
    );
  }
}

extension TrainingLegacyAdapter on Training {
  TrainingModel toLegacy({Color color = primaryColor}) => TrainingModel(
        id: id,
        userId: userId,
        date: date,
        comments: comments,
        splitLength: splitDistance.value,
        lapLength: lapDistance.value,
        maxlaps: maxLaps,
        distanceUnit: splitDistance.unit.symbol,
        speedUnit: speedUnit.symbol,
        color: color,
      );
}
