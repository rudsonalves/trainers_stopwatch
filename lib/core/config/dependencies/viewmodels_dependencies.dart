import 'package:auto_injector/auto_injector.dart';

import '/application/stopwatch/bloc/stopwatch_bloc.dart';
import '/application/stopwatch/session/stopwatch_session_view_model.dart';
import '/common/adapters/legacy_settings_sink.dart';
import '/common/constants.dart';
import '/data/repositories/settings/settings_repository.dart';
import '/domain/common/settings/models/settings.dart';
import '/domain/common/training/models/training.dart';
import '/domain/usecases/trainings/create_training_use_case.dart';
import '/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';
import '/ui/app/app_appearance_state.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';
import '/ui/pages/stopwatch/stopwatch_page_view_model.dart';

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
    ..addSingleton<StopwatchPageViewModel>(
      () => StopwatchPageViewModel(
        sessionFactory: (user) {
          final settingsRepository = injector.get<SettingsRepository>();
          final settings =
              settingsRepository.current ?? Settings.create().value!;
          final training = Training.create(
            userId: user.id!,
            date: DateTime.now(),
            splitDistance: settings.splitDistance,
            lapDistance: settings.lapDistance,
          ).value!;
          return StopwatchSessionViewModel(
            user: user,
            training: training,
            bloc: StopwatchBloc(tickInterval: settings.refreshInterval),
            createTrainingUseCase: injector.get<CreateTrainingUseCase>(),
            persistSnapshotUseCase:
                injector.get<PersistStopwatchSnapshotUseCase>(),
            colorValue: primaryColor.toARGB32(),
          );
        },
      ),
    );
}
