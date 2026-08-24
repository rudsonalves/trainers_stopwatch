import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/adapters/legacy_settings_sink.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';
import 'package:trainers_stopwatch/core/bootstrap/bootstrap.dart';
import 'package:trainers_stopwatch/core/config/dependencies.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/data/repositories/settings/settings_repository.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/data/services/database/database_provider.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';
import 'package:trainers_stopwatch/data/services/images/image_compression_service.dart';
import 'package:trainers_stopwatch/data/services/images/image_selection_service.dart';
import 'package:trainers_stopwatch/data/services/images/user_image_storage_service.dart';
import 'package:trainers_stopwatch/data/services/settings/settings_service.dart';
import 'package:trainers_stopwatch/domain/usecases/trainings/create_training_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/users/users_use_case.dart';
import 'package:trainers_stopwatch/ui/app/app_appearance_state.dart';
import 'package:trainers_stopwatch/ui/pages/settings/viewmodel/settings_view_model.dart';
import 'package:trainers_stopwatch/ui/pages/stopwatch/stopwatch_page_view_model.dart';

void main() {
  test('setupDependencies is idempotent and resolves the bootstrap graph', () {
    setupDependencies();
    final firstProvider = injector.get<DatabaseProvider>();
    final database = injector.get<DatabaseService>();
    final settingsService = injector.get<SettingsService>();
    final settingsRepository = injector.get<SettingsRepository>();
    final userRepository = injector.get<UserRepository>();
    final trainingRepository = injector.get<TrainingRepository>();
    final historyRepository = injector.get<HistoryRepository>();
    final appearanceState = injector.get<AppAppearanceState>();
    final settingsViewModel = injector.get<SettingsViewModel>();
    final legacySettings = injector.get<LegacySettingsSink>();
    final imageSelection = injector.get<ImageSelectionService>();
    final imageCompression = injector.get<ImageCompressionService>();
    final imageStorage = injector.get<UserImageStorageService>();
    final usersUseCase = injector.get<UsersUseCase>();
    final createTrainingUseCase = injector.get<CreateTrainingUseCase>();
    final stopwatchPageViewModel = injector.get<StopwatchPageViewModel>();
    addTearDown(settingsViewModel.dispose);

    setupDependencies();
    final bootstrap = injector.get<Bootstrap>();

    expect(firstProvider, isA<DatabaseProvider>());
    expect(bootstrap, isA<Bootstrap>());
    expect(injector.get<DatabaseService>(), same(database));
    expect(injector.get<SettingsService>(), isNot(same(settingsService)));
    expect(injector.get<SettingsRepository>(), same(settingsRepository));
    expect(injector.get<UserRepository>(), same(userRepository));
    expect(injector.get<TrainingRepository>(), same(trainingRepository));
    expect(injector.get<HistoryRepository>(), same(historyRepository));
    expect(injector.get<AppAppearanceState>(), same(appearanceState));
    final nextSettingsViewModel = injector.get<SettingsViewModel>();
    addTearDown(nextSettingsViewModel.dispose);
    expect(nextSettingsViewModel, isNot(same(settingsViewModel)));
    expect(legacySettings, same(injector.get<AppSettings>()));
    expect(injector.get<ImageSelectionService>(), same(imageSelection));
    expect(injector.get<ImageCompressionService>(), same(imageCompression));
    expect(injector.get<UserImageStorageService>(), same(imageStorage));
    expect(injector.get<UsersUseCase>(), isNot(same(usersUseCase)));
    expect(
      injector.get<CreateTrainingUseCase>(),
      isNot(same(createTrainingUseCase)),
    );
    expect(
      injector.get<StopwatchPageViewModel>(),
      same(stopwatchPageViewModel),
    );
  });
}
