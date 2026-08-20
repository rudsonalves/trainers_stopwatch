import 'package:auto_injector/auto_injector.dart';

import '/common/adapters/legacy_settings_sink.dart';
import '/data/repositories/settings/settings_repository.dart';
import '/domain/common/settings/models/settings.dart';
import '/ui/app/app_appearance_state.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';

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
    );
}
