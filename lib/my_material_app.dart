import 'package:flutter/material.dart';

import 'common/theme/color_schemes.g.dart';
import 'screens/athletes_page/athletes_page.dart';
import 'screens/stopwatch_page/stopwatch_page.dart';

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: StopWatchPage.routeName,
      routes: {
        StopWatchPage.routeName: (context) => const StopWatchPage(),
        AthletesPage.routeName: (context) => const AthletesPage(),
      },
    );
  }
}
