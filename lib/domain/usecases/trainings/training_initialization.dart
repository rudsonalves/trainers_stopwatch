import '/domain/common/history/models/history_entry.dart';
import '/domain/common/training/models/training.dart';

class TrainingInitialization {
  final Training training;
  final HistoryEntry initialHistory;

  const TrainingInitialization({
    required this.training,
    required this.initialHistory,
  });
}
