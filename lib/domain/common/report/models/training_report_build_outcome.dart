import 'training_report_content.dart';
import 'training_report_issue.dart';

enum TrainingReportBuildStatus {
  empty,
  complete,
  partial,
  rejected,
}

class TrainingReportBuildOutcome {
  final TrainingReportContent content;
  final List<TrainingReportIssue> issues;

  TrainingReportBuildOutcome({
    required this.content,
    required List<TrainingReportIssue> issues,
  }) : issues = List.unmodifiable(issues);

  int get validTrainingCount => content.sections.length;

  int get rejectedTrainingCount => issues.length;

  bool get hasContent => content.sections.isNotEmpty;

  bool get hasIssues => issues.isNotEmpty;

  TrainingReportBuildStatus get status {
    if (!hasContent && !hasIssues) {
      return TrainingReportBuildStatus.empty;
    }
    if (!hasIssues) {
      return TrainingReportBuildStatus.complete;
    }
    if (!hasContent) {
      return TrainingReportBuildStatus.rejected;
    }
    return TrainingReportBuildStatus.partial;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportBuildOutcome &&
          content == other.content &&
          _listEquals(issues, other.issues);

  @override
  int get hashCode => Object.hash(
        content,
        Object.hashAll(issues),
      );

  bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }
}
