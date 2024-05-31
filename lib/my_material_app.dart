import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'common/singletons/app_settings.dart';
import 'common/theme/theme.dart';
import 'common/theme/util.dart';
import 'models/settings_model.dart';
import 'screens/about_page/about_page.dart';
import 'screens/athletes_page/athletes_overlay.dart';
import 'screens/history_page/history_page.dart';
import 'screens/settings/settings_page.dart';
import 'screens/stopwatch_page/stopwatch_overlay.dart';
import 'screens/personal_training_page/personal_training_page.dart';
import 'screens/trainings_page/trainings_page.dart';

class MyMaterialApp extends StatelessWidget {
  MyMaterialApp({super.key});

  final settings = AppSettings.instance;

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

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: settings.brightnessMode.watch(context) == Brightness.light
          ? lightContrast(theme, settings.contrastMode.watch(context))
          : darkContrast(theme, settings.contrastMode.watch(context)),
      debugShowCheckedModeBanner: false,
      initialRoute: StopwatchOverlay.routeName,
      routes: {
        StopwatchOverlay.routeName: (context) => const StopwatchOverlay(),
        AthletesOverlay.routeName: (context) => const AthletesOverlay(),
        PersonalTrainingPage.routeName: (context) =>
            PersonalTrainingPage.fromContext(context),
        TrainingsPage.routeName: (context) => const TrainingsPage(),
        SettingsPage.routeName: (context) => const SettingsPage(),
        AboutPage.routeName: (context) => const AboutPage(),
        HistoryPage.routeName: (context) => HistoryPage.fromContext(context),
      },
    );
  }
}
