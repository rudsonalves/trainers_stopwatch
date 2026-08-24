import '/core/result/result.dart';
import '/domain/common/user/models/user.dart';

class StopwatchSessionId {
  final int userId;

  const StopwatchSessionId._(this.userId);

  static Result<StopwatchSessionId> fromUser(User user) {
    final userId = user.id;
    if (userId == null || userId <= 0) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A stopwatch session requires a persisted user.',
          details: userId,
        ),
      );
    }

    return Success(StopwatchSessionId._(userId));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopwatchSessionId && userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'StopwatchSessionId($userId)';
}
