import '../../user/models/user.dart';
import 'training_report_section.dart';

class TrainingReportContent {
  final User user;
  final List<TrainingReportSection> sections;

  TrainingReportContent({
    required this.user,
    required List<TrainingReportSection> sections,
  }) : sections = List.unmodifiable(sections);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportContent &&
          user == other.user &&
          _listEquals(sections, other.sections);

  @override
  int get hashCode => Object.hash(user, Object.hashAll(sections));

  bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }
}
