import '../../../domain/common/training/values/speed.dart';

class TrainingValueFormatter {
  const TrainingValueFormatter._();

  static String formatDuration(Duration duration) {
    var seconds = duration.inMilliseconds / 1000;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(2)} s';
    }

    if (seconds < 3600) {
      final minutes = duration.inMinutes;
      seconds -= minutes * 60;
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toStringAsFixed(2)} s';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes;
    seconds -= hours * 3600 - minutes * 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toStringAsFixed(2)} s';
  }

  static String formatSpeed(Speed speed) =>
      '${speed.value.toStringAsFixed(2)} ${speed.unit.symbol}';
}
