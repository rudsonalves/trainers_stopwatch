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
import 'common/functions/share_functions.dart';
import 'core/bootstrap/bootstrap.dart';
import 'core/config/dependencies.dart';
import 'features/history_page/history_page_controller.dart';
import 'features/stopwatch_page/stopwatch_page_controller.dart';
import 'features/trainings_page/trainings_page_controller.dart';
import 'ui/app/app_appearance_state.dart';
import 'ui/app/bootstrap_error_app.dart';
import 'ui/app/my_material_app.dart';
import 'ui/pages/settings/settings_view_model.dart';
import 'ui/pages/users/users_view_model_factory.dart';

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
        stopwatchController: injector.get<StopwatchPageController>(),
        usersViewModelFactory: injector.get<UsersViewModelFactory>().create,
        trainingsControllerFactory: () =>
            injector.get<TrainingsPageController>(),
        historyControllerFactory: () => injector.get<HistoryPageController>(),
        appShare: injector.get<AppShare>(),
        appearanceState: injector.get<AppAppearanceState>(),
        settingsViewModelFactory: () => injector.get<SettingsViewModel>(),
      ),
    ),
  );
}
