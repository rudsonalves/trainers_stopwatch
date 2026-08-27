import '/domain/common/training/values/speed.dart';
import 'stopwatch_session_id.dart';

enum StopwatchSessionMessageType { started, split, lap, finished }

class StopwatchSessionMessageId {
  final StopwatchSessionId sessionId;
  final int snapshotRevision;
  final StopwatchSessionMessageType type;

  const StopwatchSessionMessageId({
    required this.sessionId,
    required this.snapshotRevision,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopwatchSessionMessageId &&
          sessionId == other.sessionId &&
          snapshotRevision == other.snapshotRevision &&
          type == other.type;

  @override
  int get hashCode => Object.hash(sessionId, snapshotRevision, type);
}

class StopwatchSessionMessage implements Comparable<StopwatchSessionMessage> {
  final StopwatchSessionMessageId id;
  final DateTime occurredAt;
  final String userName;
  final String label;
  final Duration duration;
  final Speed? speed;
  final String comments;
  final int colorValue;

  const StopwatchSessionMessage({
    required this.id,
    required this.occurredAt,
    required this.userName,
    this.label = '',
    this.duration = Duration.zero,
    this.speed,
    this.comments = '',
    required this.colorValue,
  });

  StopwatchSessionMessageType get type => id.type;

  @override
  int compareTo(StopwatchSessionMessage other) {
    final dateOrder = occurredAt.compareTo(other.occurredAt);
    if (dateOrder != 0) return dateOrder;

    final sessionOrder = id.sessionId.userId.compareTo(
      other.id.sessionId.userId,
    );
    if (sessionOrder != 0) return sessionOrder;

    final revisionOrder = id.snapshotRevision.compareTo(
      other.id.snapshotRevision,
    );
    if (revisionOrder != 0) return revisionOrder;

    return id.type.index.compareTo(other.id.type.index);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopwatchSessionMessage &&
          id == other.id &&
          occurredAt == other.occurredAt &&
          userName == other.userName &&
          label == other.label &&
          duration == other.duration &&
          speed == other.speed &&
          comments == other.comments &&
          colorValue == other.colorValue;

  @override
  int get hashCode => Object.hash(
        id,
        occurredAt,
        userName,
        label,
        duration,
        speed,
        comments,
        colorValue,
      );
}
