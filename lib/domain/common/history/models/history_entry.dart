import '/core/result/result.dart';

enum HistorySnapshotType { split, lap, finish }

class HistoryEntry {
  final int? id;
  final int trainingId;
  final Duration duration;
  final String? comments;
  final int? snapshotRevision;
  final HistorySnapshotType? snapshotType;

  const HistoryEntry._({
    this.id,
    required this.trainingId,
    required this.duration,
    this.comments,
    this.snapshotRevision,
    this.snapshotType,
  });

  static Result<HistoryEntry> create({
    int? id,
    required int trainingId,
    required Duration duration,
    String? comments,
    int? snapshotRevision,
    HistorySnapshotType? snapshotType,
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

    if ((snapshotRevision == null) != (snapshotType == null) ||
        (snapshotRevision != null && snapshotRevision <= 0)) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message:
              'Snapshot revision and type must identify the same session write.',
          details: (revision: snapshotRevision, type: snapshotType),
        ),
      );
    }

    return Success(
      HistoryEntry._(
        id: id,
        trainingId: trainingId,
        duration: duration,
        comments: comments,
        snapshotRevision: snapshotRevision,
        snapshotType: snapshotType,
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
          comments == other.comments &&
          snapshotRevision == other.snapshotRevision &&
          snapshotType == other.snapshotType;

  @override
  int get hashCode => Object.hash(
        id,
        trainingId,
        duration,
        comments,
        snapshotRevision,
        snapshotType,
      );
}
