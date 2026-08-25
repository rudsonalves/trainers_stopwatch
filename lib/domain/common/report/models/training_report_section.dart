import '../../training/models/training.dart';
import 'training_report_row.dart';
import 'training_report_totals.dart';

class TrainingReportSection {
  final Training training;
  final List<TrainingReportRow> rows;
  final TrainingReportTotals totals;

  TrainingReportSection({
    required this.training,
    required List<TrainingReportRow> rows,
    required this.totals,
  }) : rows = List.unmodifiable(rows);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportSection &&
          training == other.training &&
          _listEquals(rows, other.rows) &&
          totals == other.totals;

  @override
  int get hashCode => Object.hash(
        training,
        Object.hashAll(rows),
        totals,
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
