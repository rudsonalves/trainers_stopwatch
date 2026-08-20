import '/core/result/result.dart';
import '../values/speed.dart';

enum TrainingEventOrigin { persisted, derived }

sealed class TrainingEvent {
  final int? historyId;
  final String? comments;
  final TrainingEventOrigin origin;

  const TrainingEvent({
    this.historyId,
    this.comments,
    required this.origin,
  });

  bool get isPersisted => origin == TrainingEventOrigin.persisted;

  bool get isDerived => origin == TrainingEventOrigin.derived;
}

final class TrainingStarted extends TrainingEvent {
  const TrainingStarted({super.historyId, super.comments})
      : super(origin: TrainingEventOrigin.persisted);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingStarted &&
          historyId == other.historyId &&
          comments == other.comments;

  @override
  int get hashCode => Object.hash(historyId, comments);
}

final class SplitRecorded extends TrainingEvent {
  final int splitIndex;
  final Duration duration;
  final Speed speed;

  const SplitRecorded._({
    super.historyId,
    super.comments,
    required this.splitIndex,
    required this.duration,
    required this.speed,
  }) : super(origin: TrainingEventOrigin.persisted);

  static Result<SplitRecorded> create({
    int? historyId,
    String? comments,
    required int splitIndex,
    required Duration duration,
    required Speed speed,
  }) {
    final error = _validateMeasuredEvent(index: splitIndex, duration: duration);
    if (error != null) return Failure(error);

    return Success(
      SplitRecorded._(
        historyId: historyId,
        comments: comments,
        splitIndex: splitIndex,
        duration: duration,
        speed: speed,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitRecorded &&
          historyId == other.historyId &&
          comments == other.comments &&
          splitIndex == other.splitIndex &&
          duration == other.duration &&
          speed == other.speed;

  @override
  int get hashCode =>
      Object.hash(historyId, comments, splitIndex, duration, speed);
}

final class LapRecorded extends TrainingEvent {
  final int lapIndex;
  final Duration duration;
  final Speed speed;

  const LapRecorded._({
    super.historyId,
    super.comments,
    required this.lapIndex,
    required this.duration,
    required this.speed,
  }) : super(origin: TrainingEventOrigin.derived);

  static Result<LapRecorded> create({
    int? historyId,
    String? comments,
    required int lapIndex,
    required Duration duration,
    required Speed speed,
  }) {
    final error = _validateMeasuredEvent(index: lapIndex, duration: duration);
    if (error != null) return Failure(error);

    return Success(
      LapRecorded._(
        historyId: historyId,
        comments: comments,
        lapIndex: lapIndex,
        duration: duration,
        speed: speed,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LapRecorded &&
          historyId == other.historyId &&
          comments == other.comments &&
          lapIndex == other.lapIndex &&
          duration == other.duration &&
          speed == other.speed;

  @override
  int get hashCode =>
      Object.hash(historyId, comments, lapIndex, duration, speed);
}

AppError? _validateMeasuredEvent({
  required int index,
  required Duration duration,
}) {
  if (index <= 0) {
    return AppError(
      code: AppErrorCode.invalidData,
      message: 'Training event index must be greater than zero.',
      details: index,
    );
  }

  if (duration.isNegative) {
    return AppError(
      code: AppErrorCode.invalidData,
      message: 'Training event duration cannot be negative.',
      details: duration,
    );
  }

  return null;
}
