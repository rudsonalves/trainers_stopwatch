import '../../core/result/result.dart';
import '../../domain/common/history/models/history_entry.dart';
import '../models/history_model.dart';

// Temporary legacy bridge. Remove with the history migration in backlog 006.
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
