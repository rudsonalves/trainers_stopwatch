import '/core/result/result.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import 'stopwatch_session_id.dart';
import 'stopwatch_session_message.dart';
import 'stopwatch_session_write.dart';

enum StopwatchSessionInitializationStatus { uninitialized, loading, ready }

enum StopwatchSessionPersistenceStatus { synchronized, writing, failed }

class StopwatchSessionState {
  static const _absent = Object();

  final StopwatchSessionId id;
  final User user;
  final Training? training;
  final StopwatchSessionInitializationStatus initializationStatus;
  final StopwatchSessionPersistenceStatus persistenceStatus;
  final StopwatchSessionWrite? pendingWrite;
  final List<StopwatchSessionMessage> messages;
  final AppError? error;

  StopwatchSessionState({
    required this.id,
    required this.user,
    this.training,
    this.initializationStatus =
        StopwatchSessionInitializationStatus.uninitialized,
    this.persistenceStatus = StopwatchSessionPersistenceStatus.synchronized,
    this.pendingWrite,
    List<StopwatchSessionMessage> messages = const [],
    this.error,
  }) : messages = List.unmodifiable(messages);

  StopwatchSessionState copyWith({
    User? user,
    Object? training = _absent,
    StopwatchSessionInitializationStatus? initializationStatus,
    StopwatchSessionPersistenceStatus? persistenceStatus,
    Object? pendingWrite = _absent,
    List<StopwatchSessionMessage>? messages,
    Object? error = _absent,
  }) {
    return StopwatchSessionState(
      id: id,
      user: user ?? this.user,
      training:
          identical(training, _absent) ? this.training : training as Training?,
      initializationStatus: initializationStatus ?? this.initializationStatus,
      persistenceStatus: persistenceStatus ?? this.persistenceStatus,
      pendingWrite: identical(pendingWrite, _absent)
          ? this.pendingWrite
          : pendingWrite as StopwatchSessionWrite?,
      messages: messages ?? this.messages,
      error: identical(error, _absent) ? this.error : error as AppError?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopwatchSessionState &&
          id == other.id &&
          user == other.user &&
          training == other.training &&
          initializationStatus == other.initializationStatus &&
          persistenceStatus == other.persistenceStatus &&
          pendingWrite == other.pendingWrite &&
          _listsEqual(messages, other.messages) &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
        id,
        user,
        training,
        initializationStatus,
        persistenceStatus,
        pendingWrite,
        Object.hashAll(messages),
        error,
      );
}

bool _listsEqual<T>(List<T> first, List<T> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
