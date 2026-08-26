// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.
//
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'common/constants.dart';
import 'core/bootstrap/bootstrap.dart';
import 'core/config/dependencies.dart';
import 'data/repositories/histories/history_repository.dart';
import 'data/repositories/trainings/training_repository.dart';
import 'data/repositories/users/user_repository.dart';
import 'domain/usecases/reports/send_training_report_email_use_case.dart';
import 'domain/usecases/reports/share_training_report_use_case.dart';
import 'domain/usecases/users/users_use_case.dart';
import 'ui/app/app_appearance_state.dart';
import 'ui/app/bootstrap_error_app.dart';
import 'ui/app/my_material_app.dart';
import 'ui/pages/history/viewmodel/history_view_model.dart';
import 'ui/pages/settings/viewmodel/settings_view_model.dart';
import 'ui/pages/stopwatch/stopwatch_page_view_model.dart';
import 'ui/pages/trainings/viewmodel/trainings_view_model.dart';
import 'ui/pages/users/viewmodel/users_view_model.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();

  setupDependencies();
  final result = await injector.get<Bootstrap>().initialize();

  if (result.isFailure) {
    runApp(BootstrapErrorApp(error: result.error!));
    FlutterNativeSplash.remove();
    return;
  }

  runApp(
    EasyLocalization(
      supportedLocales: appLanguages.values.map((item) => item.locale).toList(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: MyMaterialApp(
        stopwatchViewModel: injector.get<StopwatchPageViewModel>(),
        usersViewModelFactory: (activeUserIds) => UsersViewModel(
          useCase: injector.get<UsersUseCase>(),
          initiallySelectedUserIds: activeUserIds,
        ),
        trainingsViewModelFactory: () => TrainingsViewModel(
          userRepository: injector.get<UserRepository>(),
          trainingRepository: injector.get<TrainingRepository>(),
          shareTrainingReport: injector.get<ShareTrainingReportUseCase>(),
          sendTrainingReportEmail:
              injector.get<SendTrainingReportEmailUseCase>(),
        ),
        historyViewModelFactory: (training) => HistoryViewModel(
          training: training,
          historyRepository: injector.get<HistoryRepository>(),
        ),
        appearanceState: injector.get<AppAppearanceState>(),
        settingsViewModelFactory: () => injector.get<SettingsViewModel>(),
      ),
    ),
  );
}
