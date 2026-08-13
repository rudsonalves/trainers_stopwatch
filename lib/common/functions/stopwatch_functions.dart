// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.
//
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../domain/common/training/services/speed_calculator.dart';
import '../../domain/common/training/values/distance.dart';
import '../adapters/training_domain_adapter.dart';
import '../models/training_model.dart';
import '../presentation/training_value_formatter.dart';

class SpeedValue {
  final double value;
  final String speedUnit;

  const SpeedValue([
    this.value = 0,
    this.speedUnit = 'm/s',
  ]);

  @override
  String toString() {
    return '${value.toStringAsFixed(2)} $speedUnit';
  }
}

class StopwatchFunctions {
  StopwatchFunctions._();

  static SpeedValue speedCalc({
    required double length,
    required double time,
    required TrainingModel training,
  }) {
    final domainTraining = training.toDomain();
    if (domainTraining.isFailure) throw domainTraining.error!;

    final distance = Distance.create(
      value: length,
      unit: domainTraining.value!.splitDistance.unit,
    );
    if (distance.isFailure) throw distance.error!;

    final duration = Duration(microseconds: (time * 1000000).round());
    final speed = const SpeedCalculator().calculate(
      distance: distance.value!,
      duration: duration,
      outputUnit: domainTraining.value!.speedUnit,
    );
    if (speed.isFailure) throw speed.error!;

    return SpeedValue(speed.value!.value, speed.value!.unit.symbol);
  }

  static String formatDuration(Duration duration) {
    return TrainingValueFormatter.formatDuration(duration);
  }
}
