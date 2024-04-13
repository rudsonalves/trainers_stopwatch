import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'common/singletons/app_settings.dart';
import 'common/theme/color_schemes.g.dart';
import 'screens/athletes_page/athletes_page.dart';
import 'screens/stopwatch_page/stopwatch_page.dart';
import 'screens/personal_training_page/personal_training_page.dart';

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      themeMode: settings.themeMode.watch(context),
      debugShowCheckedModeBanner: false,
      initialRoute: StopWatchPage.routeName,
      routes: {
        StopWatchPage.routeName: (context) => const StopWatchPage(),
        AthletesPage.routeName: (context) => const AthletesPage(),
        PersonalTrainingPage.routeName: (context) =>
            PersonalTrainingPage.fromContext(context),
      },
    );
  }
}
