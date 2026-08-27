import '/core/result/result.dart';
import '/domain/common/stopwatch/models/stopwatch_snapshot.dart';

enum StopwatchSessionWriteType { split, lap, finish }

class StopwatchSessionWrite {
  final int trainingId;
  final int snapshotRevision;
  final StopwatchSessionWriteType type;
  final StopwatchSnapshot snapshot;
  final String? comments;

  const StopwatchSessionWrite._({
    required this.trainingId,
    required this.snapshotRevision,
    required this.type,
    required this.snapshot,
    this.comments,
  });

  static Result<StopwatchSessionWrite> create({
    required int trainingId,
    required int snapshotRevision,
    required StopwatchSnapshot snapshot,
    String? comments,
  }) {
    if (trainingId <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A session write requires a persisted training.',
          details: trainingId,
        ),
      );
    }
    if (snapshotRevision <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Snapshot revision must be greater than zero.',
          details: snapshotRevision,
        ),
      );
    }

    return Success(
      StopwatchSessionWrite._(
        trainingId: trainingId,
        snapshotRevision: snapshotRevision,
        type: switch (snapshot) {
          SplitSnapshot() => StopwatchSessionWriteType.split,
          LapSnapshot() => StopwatchSessionWriteType.lap,
          FinishSnapshot() => StopwatchSessionWriteType.finish,
        },
        snapshot: snapshot,
        comments: comments,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopwatchSessionWrite &&
          trainingId == other.trainingId &&
          snapshotRevision == other.snapshotRevision &&
          type == other.type &&
          snapshot == other.snapshot &&
          comments == other.comments;

  @override
  int get hashCode =>
      Object.hash(trainingId, snapshotRevision, type, snapshot, comments);
}
