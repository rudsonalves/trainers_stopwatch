import '../../training/values/distance.dart';
import '../../training/values/speed.dart';

class TrainingReportTotals {
  final Distance distance;
  final Duration duration;
  final int lapCount;
  final Speed averageSpeed;

  const TrainingReportTotals({
    required this.distance,
    required this.duration,
    required this.lapCount,
    required this.averageSpeed,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportTotals &&
          distance == other.distance &&
          duration == other.duration &&
          lapCount == other.lapCount &&
          averageSpeed == other.averageSpeed;

  @override
  int get hashCode => Object.hash(
        distance,
        duration,
        lapCount,
        averageSpeed,
      );
}
