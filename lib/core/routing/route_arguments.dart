import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '../../ui/pages/stopwatch/session/stopwatch_session_id.dart';

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
