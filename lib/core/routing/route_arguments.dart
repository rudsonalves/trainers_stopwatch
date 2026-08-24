import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '/application/stopwatch/session/stopwatch_session_view_model.dart';

class PersonalTrainingRouteArguments {
  final StopwatchSessionViewModel session;

  const PersonalTrainingRouteArguments({required this.session});
}

class HistoryRouteArguments {
  final User user;
  final Training training;

  const HistoryRouteArguments({
    required this.user,
    required this.training,
  });
}
