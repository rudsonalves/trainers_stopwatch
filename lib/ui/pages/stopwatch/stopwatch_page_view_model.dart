import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '/core/result/result.dart';
import '/domain/common/user/models/user.dart';
import 'bloc/stopwatch_state.dart';
import 'session/stopwatch_session_id.dart';
import 'session/stopwatch_session_message.dart';
import 'session/stopwatch_session_view_model.dart';

typedef StopwatchSessionFactory = StopwatchSessionViewModel Function(User user);

class StopwatchPageViewModel extends ChangeNotifier {
  final StopwatchSessionFactory _sessionFactory;

  StopwatchPageViewModel({
    required StopwatchSessionFactory sessionFactory,
  }) : _sessionFactory = sessionFactory;

  final LinkedHashMap<StopwatchSessionId, StopwatchSessionViewModel> _sessions =
      LinkedHashMap();

  final Map<StopwatchSessionId, VoidCallback> _sessionListeners = {};

  final Set<StopwatchSessionId> _removingSessionIds = {};

  bool isRemoving(StopwatchSessionId id) => _removingSessionIds.contains(id);

  Set<int> get activeUserIds => Set.unmodifiable(
        _sessions.keys.map((id) => id.userId),
      );

  bool _closed = false;
  bool _notifierDisposed = false;
  Future<void>? _closing;

  StopwatchSessionViewModel? sessionById(StopwatchSessionId id) =>
      _sessions[id];

  List<StopwatchSessionViewModel> get sessions =>
      List.unmodifiable(_sessions.values);

  List<StopwatchSessionMessage> get messages {
    final result = _sessions.values
        .expand((session) => session.state.messages)
        .toList(growable: false)
      ..sort();

    return List.unmodifiable(result);
  }

  @override
  void dispose() {
    if (_notifierDisposed) {
      return;
    }

    _closed = true;
    unawaited(close());

    _notifierDisposed = true;
    super.dispose();
  }

  Result<Unit> addUsers(Iterable<User> users) {
    if (_closed) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'The stopwatch page view model is closed.',
        ),
      );
    }

    final pending = <StopwatchSessionId, User>{};

    for (final user in users) {
      final idRequest = StopwatchSessionId.fromUser(user);
      if (idRequest.isFailure) {
        return Failure(idRequest.error!);
      }

      final id = idRequest.value!;
      if (!_sessions.containsKey(id)) {
        pending[id] = user;
      }
    }

    if (pending.isEmpty) return const Success(unit);

    for (final entry in pending.entries) {
      final id = entry.key;
      final user = entry.value;

      final session = _sessionFactory(user);

      session.addListener(_onSessionChanged);
      _sessionListeners[id] = _onSessionChanged;
      _sessions[id] = session;
    }

    notifyListeners();
    return const Success(unit);
  }

  bool requiresRemovalConfirmation(StopwatchSessionId id) {
    final session = _sessions[id];
    if (session == null) {
      return false;
    }

    return session.bloc.state.status == StopwatchStatus.running ||
        session.bloc.state.status == StopwatchStatus.paused;
  }

  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    _closed = true;

    final entries = _sessions.entries.toList(growable: false);
    _sessions.clear();

    for (final entry in entries) {
      final listener = _sessionListeners.remove(entry.key);

      if (listener != null) {
        entry.value.removeListener(listener);
      }

      await entry.value.close();
    }

    if (!_notifierDisposed) {
      _notifierDisposed = true;
      super.dispose();
    }

    _removingSessionIds.clear();
  }

  AsyncResult<Unit> removeSession(
    StopwatchSessionId id, {
    bool confirmed = false,
  }) async {
    if (_closed) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'The stopwatch page view model is closed.',
        ),
      );
    }

    final session = _sessions[id];
    if (session == null) {
      return const Success(unit);
    }

    if (!_removingSessionIds.add(id)) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Session removal is already running.',
        ),
      );
    }

    notifyListeners();

    try {
      final requiresConfirmation = requiresRemovalConfirmation(id);

      if (requiresConfirmation && !confirmed) {
        return const Failure(
          AppError(
            code: AppErrorCode.invalidData,
            message: 'Active session removal requires confirmation.',
          ),
        );
      }

      if (requiresConfirmation) {
        final finishResult = await session.finish();

        if (finishResult.isFailure) {
          return Failure(finishResult.error!);
        }
      }

      if (session.hasPendingWrite) {
        return const Failure(
          AppError(
            code: AppErrorCode.storageWriteFailed,
            message: 'The session still has a pending write.',
          ),
        );
      }

      final listener = _sessionListeners.remove(id);
      if (listener != null) {
        session.removeListener(listener);
      }

      _sessions.remove(id);
      await session.close();

      return const Success(unit);
    } finally {
      _removingSessionIds.remove(id);

      if (!_closed) {
        notifyListeners();
      }
    }
  }

  void _onSessionChanged() {
    if (!_closed) {
      notifyListeners();
    }
  }
}
