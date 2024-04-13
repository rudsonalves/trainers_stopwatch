import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';

class AppSettings {
  AppSettings._();
  static final _instance = AppSettings._();
  static AppSettings get instance => _instance;

  late final String _imagePath;
  late final Directory _appDocDir;
  int millisecondRefresh = 66;
  double splitLength = 200;
  double lapLength = 1000;
  final _themeMode = signal<ThemeMode>(ThemeMode.dark);

  String get imagePath => _imagePath;
  Signal<ThemeMode> get themeMode => _themeMode;

  Future<void> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _imagePath = '${_appDocDir.path}/athletes_images';

    final athletesImageDir = Directory(_imagePath);
    if (!await athletesImageDir.exists()) {
      await athletesImageDir.create(recursive: true);
    }
  }

  void toggleThemeMode() {
    _themeMode.value =
        _themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
