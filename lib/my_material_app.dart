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

import 'common/singletons/app_settings.dart';
import 'common/theme/theme.dart';
import 'common/theme/util.dart';
import 'features/settings/settings_overlay.dart';
import 'common/models/settings_model.dart';
import 'features/about_page/about_page.dart';
import 'features/trainings_page/trainings_overlay.dart';
import 'features/users_page/users_overlay.dart';
import 'features/history_page/history_page.dart';
import 'features/stopwatch_page/stopwatch_overlay.dart';
import 'features/personal_training_page/personal_training_page.dart';

class MyMaterialApp extends StatelessWidget {
  MyMaterialApp({super.key});

  final app = AppSettings.instance;

  ThemeData lightContrast(MaterialTheme theme, Contrast contrast) {
    switch (contrast) {
      case Contrast.standard:
        return theme.light();
      case Contrast.medium:
        return theme.lightMediumContrast();
      case Contrast.high:
        return theme.lightHighContrast();
    }
  }

  ThemeData darkContrast(MaterialTheme theme, Contrast contrast) {
    switch (contrast) {
      case Contrast.standard:
        return theme.dark();
      case Contrast.medium:
        return theme.darkMediumContrast();
      case Contrast.high:
        return theme.darkHighContrast();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Actor");
    MaterialTheme theme = MaterialTheme(textTheme);

    return AnimatedBuilder(
      animation: Listenable.merge([app.brightnessMode, app.contrastMode]),
      builder: (context, _) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: app.brightnessMode.value == Brightness.light
            ? lightContrast(theme, app.contrastMode.value)
            : darkContrast(theme, app.contrastMode.value),
        debugShowCheckedModeBanner: false,
        initialRoute: StopwatchOverlay.routeName,
        routes: {
          StopwatchOverlay.routeName: (context) => const StopwatchOverlay(),
          UsersOverlay.routeName: (context) => const UsersOverlay(),
          PersonalTrainingPage.routeName: (context) =>
              PersonalTrainingPage.fromContext(context),
          TrainingsOverlay.routeName: (context) => const TrainingsOverlay(),
          SettingsOverlay.routeName: (context) => const SettingsOverlay(),
          AboutPage.routeName: (context) => const AboutPage(),
          HistoryPage.routeName: (context) => HistoryPage.fromContext(context),
        },
      ),
    );
  }
}
