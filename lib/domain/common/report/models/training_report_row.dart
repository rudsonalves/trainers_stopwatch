import '../../training/events/training_event.dart';

class TrainingReportRow {
  final TrainingEvent event;

  const TrainingReportRow({
    required this.event,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportRow && event == other.event;

  @override
  int get hashCode => event.hashCode;
}
