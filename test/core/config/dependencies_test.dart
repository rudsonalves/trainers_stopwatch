import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/bootstrap/bootstrap.dart';
import 'package:trainers_stopwatch/core/config/dependencies.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/data/repositories/settings/settings_repository.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';
import 'package:trainers_stopwatch/data/services/settings/settings_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_provider.dart';

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
  });
}
