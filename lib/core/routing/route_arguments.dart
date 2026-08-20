import '/common/models/training_model.dart';
import '/common/models/user_model.dart';
import '/features/widgets/precise_stopwatch/precise_stopwatch.dart';

final class PersonalTrainingRouteArguments {
  final PreciseStopwatch stopwatch;

  const PersonalTrainingRouteArguments({required this.stopwatch});
}

final class HistoryRouteArguments {
  final UserModel user;
  final TrainingModel training;

  const HistoryRouteArguments({
    required this.user,
    required this.training,
  });
}
