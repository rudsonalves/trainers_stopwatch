import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/domain/common/stopwatch/models/stopwatch_snapshot.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/session/stopwatch_session_id.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/session/stopwatch_session_message.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/session/stopwatch_session_state.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/session/stopwatch_session_write.dart';

const _user = User(id: 7, name: 'Ana', email: 'ana@example.com');

void main() {
  group('StopwatchSessionId', () {
    test('uses the persisted user id as stable identity', () {
      final first = StopwatchSessionId.fromUser(_user).value!;
      final second = StopwatchSessionId.fromUser(_user).value!;

      expect(first, second);
      expect(first.userId, 7);
      expect(first.hashCode, second.hashCode);
    });

    test('rejects a user without persistence identity', () {
      const transient = User(name: 'Ana', email: 'ana@example.com');

      final result = StopwatchSessionId.fromUser(transient);

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
    });
  });

  test('session write keeps revision and immutable snapshot content', () {
    final snapshot = SplitSnapshot.create(
      elapsed: const Duration(seconds: 12),
      splitDuration: const Duration(seconds: 12),
      lapCount: 0,
      splitCount: 1,
    ).value!;

    final result = StopwatchSessionWrite.create(
      trainingId: 11,
      snapshotRevision: 3,
      snapshot: snapshot,
    );

    expect(result.isSuccess, isTrue);
    expect(result.value!.trainingId, 11);
    expect(result.value!.snapshotRevision, 3);
    expect(result.value!.type, StopwatchSessionWriteType.split);
    expect(result.value!.snapshot, same(snapshot));
  });

  test('message ordering is stable when timestamps are equal', () {
    final sessionId = StopwatchSessionId.fromUser(_user).value!;
    final occurredAt = DateTime(2026, 8, 24, 10);
    final split = StopwatchSessionMessage(
      id: StopwatchSessionMessageId(
        sessionId: sessionId,
        snapshotRevision: 2,
        type: StopwatchSessionMessageType.split,
      ),
      occurredAt: occurredAt,
      userName: _user.name,
      colorValue: 0xff000000,
    );
    final lap = StopwatchSessionMessage(
      id: StopwatchSessionMessageId(
        sessionId: sessionId,
        snapshotRevision: 2,
        type: StopwatchSessionMessageType.lap,
      ),
      occurredAt: occurredAt,
      userName: _user.name,
      colorValue: 0xff000000,
    );

    expect([lap, split]..sort(), [split, lap]);
  });

  test('state exposes an immutable message collection and nullable copyWith',
      () {
    final sessionId = StopwatchSessionId.fromUser(_user).value!;
    final source = <StopwatchSessionMessage>[];
    final state = StopwatchSessionState(
      id: sessionId,
      user: _user,
      messages: source,
    );

    source.clear();
    expect(state.messages, isEmpty);
    expect(
        () => state.messages.add(_message(sessionId)), throwsUnsupportedError);

    final failed = state.copyWith(
      initializationStatus: StopwatchSessionInitializationStatus.ready,
      persistenceStatus: StopwatchSessionPersistenceStatus.failed,
      error: const AppError(
        code: AppErrorCode.storageWriteFailed,
        message: 'failed',
      ),
      messages: [_message(sessionId)],
    );
    final cleared = failed.copyWith(error: null, pendingWrite: null);

    expect(failed.messages, hasLength(1));
    expect(failed.error, isNotNull);
    expect(cleared.error, isNull);
    expect(cleared.pendingWrite, isNull);
    expect(cleared.initializationStatus,
        StopwatchSessionInitializationStatus.ready);
  });
}

StopwatchSessionMessage _message(StopwatchSessionId sessionId) =>
    StopwatchSessionMessage(
      id: StopwatchSessionMessageId(
        sessionId: sessionId,
        snapshotRevision: 1,
        type: StopwatchSessionMessageType.split,
      ),
      occurredAt: DateTime(2026, 8, 24),
      userName: _user.name,
      colorValue: 0xff000000,
    );
