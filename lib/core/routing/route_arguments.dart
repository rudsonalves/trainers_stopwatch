import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '/features/widgets/precise_stopwatch/precise_stopwatch.dart';

class PersonalTrainingRouteArguments {
  final PreciseStopwatch stopwatch;

  const PersonalTrainingRouteArguments({required this.stopwatch});
}

class HistoryRouteArguments {
  final User user;
  final Training training;

  const HistoryRouteArguments({
    required this.user,
    required this.training,
  });
}
