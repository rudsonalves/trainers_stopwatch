import '/domain/common/stopwatch/models/stopwatch_snapshot.dart';

enum StopwatchStatus {
  idle,
  running,
  paused,
  finished,
}

class StopwatchState {
  static const _absent = Object();

  final StopwatchStatus status;
  final Duration elapsed;
  final int lapCount;
  final int splitCount;
  final int? maxLaps;
  final int splitsPerLap;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final StopwatchSnapshot? snapshot;
  final int snapshotRevision;

  const StopwatchState({
    this.status = StopwatchStatus.idle,
    this.elapsed = Duration.zero,
    this.lapCount = 0,
    this.splitCount = 0,
    this.maxLaps,
    this.splitsPerLap = 1,
    this.startedAt,
    this.finishedAt,
    this.snapshot,
    this.snapshotRevision = 0,
  });

  StopwatchState copyWith({
    StopwatchStatus? status,
    Duration? elapsed,
    int? lapCount,
    int? splitCount,
    Object? maxLaps = _absent,
    int? splitsPerLap,
    Object? startedAt = _absent,
    Object? finishedAt = _absent,
    Object? snapshot = _absent,
    int? snapshotRevision,
  }) {
    return StopwatchState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      lapCount: lapCount ?? this.lapCount,
      splitCount: splitCount ?? this.splitCount,
      maxLaps: identical(maxLaps, _absent) ? this.maxLaps : maxLaps as int?,
      splitsPerLap: splitsPerLap ?? this.splitsPerLap,
      startedAt: identical(startedAt, _absent)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, _absent)
          ? this.finishedAt
          : finishedAt as DateTime?,
      snapshot: identical(snapshot, _absent)
          ? this.snapshot
          : snapshot as StopwatchSnapshot?,
      snapshotRevision: snapshotRevision ?? this.snapshotRevision,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopwatchState &&
          status == other.status &&
          elapsed == other.elapsed &&
          lapCount == other.lapCount &&
          splitCount == other.splitCount &&
          maxLaps == other.maxLaps &&
          splitsPerLap == other.splitsPerLap &&
          startedAt == other.startedAt &&
          finishedAt == other.finishedAt &&
          snapshot == other.snapshot &&
          snapshotRevision == other.snapshotRevision;

  @override
  int get hashCode => Object.hash(
        status,
        elapsed,
        lapCount,
        splitCount,
        maxLaps,
        splitsPerLap,
        startedAt,
        finishedAt,
        snapshot,
        snapshotRevision,
      );
}
