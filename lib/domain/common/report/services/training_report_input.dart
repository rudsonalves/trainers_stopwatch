import '../../history/models/history_entry.dart';
import '../../training/models/training.dart';

class TrainingReportInput {
  final Training training;
  final List<HistoryEntry> histories;

  TrainingReportInput({
    required this.training,
    required List<HistoryEntry> histories,
  }) : histories = List.unmodifiable(histories);
}
