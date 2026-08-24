import 'package:auto_injector/auto_injector.dart';

import '/domain/usecases/trainings/create_training_use_case.dart';
import '/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';
import '/domain/usecases/users/users_use_case.dart';

void registerUseCasesDependencies(AutoInjector injector) {
  injector
    ..add<UsersUseCase>(UsersUseCase.new)
    ..add<CreateTrainingUseCase>(CreateTrainingUseCase.new)
    ..add<PersistStopwatchSnapshotUseCase>(
      PersistStopwatchSnapshotUseCase.new,
    );
}
