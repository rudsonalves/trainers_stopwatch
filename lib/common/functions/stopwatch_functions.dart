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
import '../models/training_model.dart';

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
    switch (training.distanceUnit) {
      case 'km':
        length *= 1000;
        break;
      case 'yd':
        length *= 0.9144;
        break;
      case 'mi':
        length *= 1609.34;
        break;
    }

    double speed = length / time;
    switch (training.speedUnit) {
      case 'yd/s':
        speed *= 1.09361;
        break;
      case 'km/h':
        speed *= 3.6;
        break;
      case 'mph':
        speed *= 2.23694;
        break;
    }

    return SpeedValue(speed, training.speedUnit);
  }

  static String formatDuration(Duration duration) {
    double seconds = duration.inMilliseconds / 1000;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(2)} s';
    } else if (seconds < 3600) {
      final minutes = duration.inMinutes;
      seconds -= minutes * 60;
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toStringAsFixed(2)} s';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes;
      seconds -= hours * 3600 - minutes * 60;
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toStringAsFixed(2)} s';
    }
  }
}
