import 'package:auto_injector/auto_injector.dart';

import '/data/repositories/histories/history_repository.dart';
import '/data/repositories/histories/history_repository_impl.dart';
import '/data/repositories/settings/settings_repository.dart';
import '/data/repositories/settings/settings_repository_impl.dart';
import '/data/repositories/trainings/training_repository.dart';
import '/data/repositories/trainings/training_repository_impl.dart';
import '/data/repositories/users/user_repository.dart';
import '/data/repositories/users/user_repository_impl.dart';
import '/data/services/histories/history_service.dart';
import '/data/services/settings/settings_service.dart';
import '/data/services/trainings/training_service.dart';
import '/data/services/users/user_service.dart';

void registerRepositoriesDependencies(AutoInjector injector) {
  injector
    ..addSingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        service: injector.get<SettingsService>(),
      ),
    )
    ..addSingleton<UserRepository>(
      () => UserRepositoryImpl(service: injector.get<UserService>()),
    )
    ..addSingleton<TrainingRepository>(
      () => TrainingRepositoryImpl(service: injector.get<TrainingService>()),
    )
    ..addSingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(service: injector.get<HistoryService>()),
    );
}
