import '../../core/result/result.dart';
import '../../domain/common/history/models/history_entry.dart';
import '../models/history_model.dart';

// Temporary session/report bridge. Remove in backlogs 008 and 009.
extension HistoryModelDomainAdapter on HistoryModel {
  Result<HistoryEntry> toDomain() => HistoryEntry.create(
        id: id,
        trainingId: trainingId,
        duration: duration,
        comments: comments,
      );
}

extension HistoryLegacyAdapter on HistoryEntry {
  HistoryModel toLegacy() => HistoryModel(
        id: id,
        trainingId: trainingId,
        duration: duration,
        comments: comments,
      );
}
