import '../../models/training_model.dart';

class StopwatchFunctions {
  StopwatchFunctions._();

  static String speedCalc({
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

    return '${speed.toStringAsFixed(2)} ${training.speedUnit}';
  }
}
