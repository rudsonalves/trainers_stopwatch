import '/application/stopwatch/session/stopwatch_session_id.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';

class PersonalTrainingRouteArguments {
  final StopwatchSessionId sessionId;

  const PersonalTrainingRouteArguments({
    required this.sessionId,
  });
}

class HistoryRouteArguments {
  final User user;
  final Training training;

  const HistoryRouteArguments({
    required this.user,
    required this.training,
  });
}
