import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trainers_stopwatch/common/constants.dart';

import 'common/singletons/app_settings.dart';
import 'my_material_app.dart';
import 'store/database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  final dbProvider = DatabaseProvider();
  await dbProvider.init();

  final appSettings = AppSettings.instance;
  await appSettings.init();

  runApp(
    EasyLocalization(
      supportedLocales: appLanguages.values.map((item) => item.locale).toList(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyMaterialApp(),
    ),
  );
}
