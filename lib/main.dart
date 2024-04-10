import 'package:flutter/material.dart';

import 'common/singletons/app_settings.dart';
import 'my_material_app.dart';
import 'store/database_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbManager = DatabaseManager.instance;
  await dbManager.init();

  final appSettings = AppSettings.instance;
  await appSettings.init();

  runApp(const MyMaterialApp());
}
