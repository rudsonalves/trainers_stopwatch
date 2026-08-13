import 'package:auto_injector/auto_injector.dart';

import '../../common/functions/share_functions.dart';
import '../../common/singletons/app_settings.dart';
import '../../data/repositories/histories/history_repository.dart';
import '../../data/repositories/histories/history_repository_impl.dart';
import '../../data/repositories/settings/settings_repository.dart';
import '../../data/repositories/settings/settings_repository_impl.dart';
import '../../data/repositories/trainings/training_repository.dart';
import '../../data/repositories/trainings/training_repository_impl.dart';
import '../../data/repositories/users/user_repository.dart';
import '../../data/repositories/users/user_repository_impl.dart';
import '../../data/services/database/database_backup_service.dart';
import '../../data/services/database/database_provider.dart';
import '../../data/services/database/database_schema.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/database/database_service_factory.dart';
import '../../data/services/histories/history_mapper.dart';
import '../../data/services/histories/history_service.dart';
import '../../data/services/settings/settings_mapper.dart';
import '../../data/services/settings/settings_service.dart';
import '../../data/services/trainings/training_mapper.dart';
import '../../data/services/trainings/training_service.dart';
import '../../data/services/users/user_mapper.dart';
import '../../data/services/users/user_service.dart';
import '../../domain/common/settings/models/settings.dart';
import '../../features/history_page/history_page_controller.dart';
import '../../features/stopwatch_page/stopwatch_page_controller.dart';
import '../../features/trainings_page/trainings_page_controller.dart';
import '../../features/users_page/users_page_controller.dart';
import '../../features/widgets/precise_stopwatch/precise_stopwatch_controller.dart';
import '../../manager/history_manager.dart';
import '../../manager/training_manager.dart';
import '../../manager/user_manager.dart';
import '../../ui/app/app_appearance_state.dart';
import '../../ui/pages/settings/settings_view_model.dart';
import '../bootstrap/bootstrap.dart';

final injector = AutoInjector();
bool _initialized = false;

void setupDependencies() {
  if (_initialized) return;

  injector
    ..addInstance<DatabaseSchema>(const DatabaseSchema())
    ..addInstance<DatabaseBackupService>(
      DatabaseBackupService(clock: DateTime.now),
    )
    ..addInstance<SettingsMapper>(const SettingsMapper())
    ..addInstance<HistoryMapper>(const HistoryMapper())
    ..addInstance<UserMapper>(const UserMapper())
    ..addInstance<TrainingMapper>(const TrainingMapper())
    ..addSingleton<DatabaseService>(
      () => createDatabaseService(
        backupService: injector.get<DatabaseBackupService>(),
        schema: injector.get<DatabaseSchema>(),
      ),
    )
    ..add<SettingsService>(SettingsService.new)
    ..add<HistoryService>(HistoryService.new)
    ..add<UserService>(UserService.new)
    ..add<TrainingService>(TrainingService.new)
    ..addSingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        service: injector.get<SettingsService>(),
      ),
    )
    ..addSingleton<AppAppearanceState>(
      () => AppAppearanceState(
        settings: Settings.create().value!,
      ),
    )
    ..add<SettingsViewModel>(
      () => SettingsViewModel(
        repository: injector.get<SettingsRepository>(),
        appearanceState: injector.get<AppAppearanceState>(),
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
    )
    ..addInstance<AppSettings>(AppSettings.instance)
    ..addSingleton<AppShare>(AppShare.new)
    ..add<UserManager>(UserManager.new)
    ..add<TrainingManager>(TrainingManager.new)
    ..add<HistoryManager>(HistoryManager.new)
    ..add<UsersPageController>(UsersPageController.new)
    ..add<TrainingsPageController>(
      () => TrainingsPageController(
        usersManager: injector.get<UserManager>(),
        trainingManagerFactory: () => injector.get<TrainingManager>(),
      ),
    )
    ..add<HistoryPageController>(HistoryPageController.new)
    ..addSingleton<StopwatchPageController>(StopwatchPageController.new)
    ..add<PreciseStopwatchController>(PreciseStopwatchController.new)
    ..add<DatabaseProvider>(DatabaseProvider.new)
    ..add<Bootstrap>(Bootstrap.new)
    ..commit();

  injector.get<StopwatchPageController>().configure(
        stopwatchFactory: () => injector.get<PreciseStopwatchController>(),
      );

  _initialized = true;
}
