import '/core/result/result.dart';

class HistoryEntry {
  final int? id;
  final int trainingId;
  final Duration duration;
  final String? comments;

  const HistoryEntry._({
    this.id,
    required this.trainingId,
    required this.duration,
    this.comments,
  });

  static Result<HistoryEntry> create({
    int? id,
    required int trainingId,
    required Duration duration,
    String? comments,
  }) {
    if (trainingId <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'History entry requires a persisted training.',
          details: trainingId,
        ),
      );
    }

    if (duration.isNegative) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'History duration cannot be negative.',
          details: duration,
        ),
      );
    }

    return Success(
      HistoryEntry._(
        id: id,
        trainingId: trainingId,
        duration: duration,
        comments: comments,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntry &&
          id == other.id &&
          trainingId == other.trainingId &&
          duration == other.duration &&
          comments == other.comments;

  @override
  int get hashCode => Object.hash(id, trainingId, duration, comments);
}
