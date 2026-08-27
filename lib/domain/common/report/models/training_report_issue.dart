import '/core/result/result.dart';
import '../../training/models/training.dart';

class TrainingReportIssue {
  final Training training;
  final AppError error;

  const TrainingReportIssue({
    required this.training,
    required this.error,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportIssue &&
          training == other.training &&
          error.code == other.error.code &&
          error.message == other.error.message &&
          error.details == other.error.details;

  @override
  int get hashCode => Object.hash(
        training,
        error.code,
        error.message,
        error.details,
      );
}
