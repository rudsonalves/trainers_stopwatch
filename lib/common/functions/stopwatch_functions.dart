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

  static String formatDuration(Duration duration) {
    double seconds = duration.inMilliseconds / 1000;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(2)}s';
    } else if (seconds < 3600) {
      final minutes = duration.inMinutes;
      seconds -= minutes * 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2)}s';
    }

    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return '${durationStr.substring(0, point + 4)}s';
  }
}
