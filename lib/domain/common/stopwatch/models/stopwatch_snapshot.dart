import '/core/result/result.dart';

sealed class StopwatchSnapshot {
  final Duration elapsed;
  final int lapCount;
  final int splitCount;

  const StopwatchSnapshot({
    required this.elapsed,
    required this.lapCount,
    required this.splitCount,
  });
}

final class SplitSnapshot extends StopwatchSnapshot {
  final Duration splitDuration;

  const SplitSnapshot._({
    required super.elapsed,
    required this.splitDuration,
    required super.lapCount,
    required super.splitCount,
  });

  static Result<SplitSnapshot> create({
    required Duration elapsed,
    required Duration splitDuration,
    required int lapCount,
    required int splitCount,
  }) {
    final error = _validateSnapshot(
      elapsed: elapsed,
      durations: [splitDuration],
      lapCount: lapCount,
      splitCount: splitCount,
    );
    if (error != null) return Failure(error);

    return Success(
      SplitSnapshot._(
        elapsed: elapsed,
        splitDuration: splitDuration,
        lapCount: lapCount,
        splitCount: splitCount,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitSnapshot &&
          elapsed == other.elapsed &&
          splitDuration == other.splitDuration &&
          lapCount == other.lapCount &&
          splitCount == other.splitCount;

  @override
  int get hashCode => Object.hash(elapsed, splitDuration, lapCount, splitCount);
}

final class LapSnapshot extends StopwatchSnapshot {
  final Duration splitDuration;
  final Duration lapDuration;

  const LapSnapshot._({
    required super.elapsed,
    required this.splitDuration,
    required this.lapDuration,
    required super.lapCount,
    required super.splitCount,
  });

  static Result<LapSnapshot> create({
    required Duration elapsed,
    required Duration splitDuration,
    required Duration lapDuration,
    required int lapCount,
    required int splitCount,
  }) {
    final error = _validateSnapshot(
      elapsed: elapsed,
      durations: [splitDuration, lapDuration],
      lapCount: lapCount,
      splitCount: splitCount,
    );
    if (error != null) return Failure(error);

    return Success(
      LapSnapshot._(
        elapsed: elapsed,
        splitDuration: splitDuration,
        lapDuration: lapDuration,
        lapCount: lapCount,
        splitCount: splitCount,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LapSnapshot &&
          elapsed == other.elapsed &&
          splitDuration == other.splitDuration &&
          lapDuration == other.lapDuration &&
          lapCount == other.lapCount &&
          splitCount == other.splitCount;

  @override
  int get hashCode =>
      Object.hash(elapsed, splitDuration, lapDuration, lapCount, splitCount);
}

final class FinishSnapshot extends StopwatchSnapshot {
  final Duration finalSplitDuration;
  final Duration finalLapDuration;

  const FinishSnapshot._({
    required super.elapsed,
    required this.finalSplitDuration,
    required this.finalLapDuration,
    required super.lapCount,
    required super.splitCount,
  });

  static Result<FinishSnapshot> create({
    required Duration elapsed,
    required Duration finalSplitDuration,
    required Duration finalLapDuration,
    required int lapCount,
    required int splitCount,
  }) {
    final error = _validateSnapshot(
      elapsed: elapsed,
      durations: [finalSplitDuration, finalLapDuration],
      lapCount: lapCount,
      splitCount: splitCount,
    );
    if (error != null) return Failure(error);

    return Success(
      FinishSnapshot._(
        elapsed: elapsed,
        finalSplitDuration: finalSplitDuration,
        finalLapDuration: finalLapDuration,
        lapCount: lapCount,
        splitCount: splitCount,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinishSnapshot &&
          elapsed == other.elapsed &&
          finalSplitDuration == other.finalSplitDuration &&
          finalLapDuration == other.finalLapDuration &&
          lapCount == other.lapCount &&
          splitCount == other.splitCount;

  @override
  int get hashCode => Object.hash(
        elapsed,
        finalSplitDuration,
        finalLapDuration,
        lapCount,
        splitCount,
      );
}

AppError? _validateSnapshot({
  required Duration elapsed,
  required List<Duration> durations,
  required int lapCount,
  required int splitCount,
}) {
  if (elapsed.isNegative || durations.any((duration) => duration.isNegative)) {
    return const AppError(
      code: AppErrorCode.invalidData,
      message: 'Stopwatch durations cannot be negative.',
    );
  }

  if (durations.any((duration) => duration > elapsed)) {
    return const AppError(
      code: AppErrorCode.invalidData,
      message: 'A segment duration cannot exceed total elapsed time.',
    );
  }

  if (lapCount < 0 || splitCount < 0) {
    return const AppError(
      code: AppErrorCode.invalidData,
      message: 'Stopwatch counters cannot be negative.',
    );
  }

  return null;
}
