import '/core/result/result.dart';
import '/domain/common/history/models/history_entry.dart';
import '/store/constants/table_attributes.dart';

final class HistoryMapper {
  const HistoryMapper();

  Result<HistoryEntry> fromMap(Map<String, Object?> map) {
    try {
      return HistoryEntry.create(
        id: map[historyId] as int?,
        trainingId: map[historyTrainingId] as int,
        duration: Duration(milliseconds: map[historyDuration] as int),
        comments: map[historyComments] as String?,
      );
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Invalid persisted history data.',
          details: (error: error, stackTrace: stackTrace, data: map),
        ),
      );
    }
  }

  Map<String, Object?> toMap(HistoryEntry entry) => <String, Object?>{
        if (entry.id != null) historyId: entry.id,
        historyTrainingId: entry.trainingId,
        historyDuration: entry.duration.inMilliseconds,
        historyComments: entry.comments,
      };
}
