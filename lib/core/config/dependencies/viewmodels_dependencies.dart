import 'package:auto_injector/auto_injector.dart';

import '/common/adapters/legacy_settings_sink.dart';
import '/data/repositories/settings/settings_repository.dart';
import '/domain/common/settings/models/settings.dart';
import '/domain/usecases/users/users_use_case.dart';
import '/ui/app/app_appearance_state.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';
import '/ui/pages/users/viewmodel/users_view_model_factory.dart';

void registerViewModelsDependencies(AutoInjector injector) {
  injector
    ..addSingleton<AppAppearanceState>(
      () => AppAppearanceState(settings: Settings.create().value!),
    )
    ..add<SettingsViewModel>(
      () => SettingsViewModel(
        repository: injector.get<SettingsRepository>(),
        appearanceState: injector.get<AppAppearanceState>(),
        legacySettings: injector.get<LegacySettingsSink>(),
      ),
    )
    ..addSingleton<UsersViewModelFactory>(
      () => UsersViewModelFactory(
        useCaseFactory: () => injector.get<UsersUseCase>(),
      ),
    );
}
