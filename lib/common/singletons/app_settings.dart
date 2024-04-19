import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../manager/settings_manager.dart';
import '../../models/settings_model.dart';

class AppSettings extends SettingsModel {
  AppSettings._();
  static final _instance = AppSettings._();
  static AppSettings get instance => _instance;

  late final String _imagePath;
  late final Directory _appDocDir;

  late final Signal<ThemeMode> _themeMode;

  String get imagePath => _imagePath;
  Signal<ThemeMode> get themeMode => _themeMode;

  Future<void> init() async {
    // Load app Settings
    final settings = await SettingsManager.query();
    copy(settings);
    // Update ThemeMode
    _themeMode = signal<ThemeMode>(theme);

    // Start app paths
    _appDocDir = await getApplicationDocumentsDirectory();
    _imagePath = '${_appDocDir.path}/athletes_images';
    final athletesImageDir = Directory(_imagePath);
    // Create athletesImageDir in necessary
    if (!await athletesImageDir.exists()) {
      await athletesImageDir.create(recursive: true);
    }
  }

  void toggleThemeMode() {
    _themeMode.value =
        _themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    theme = _themeMode.value;
    update();
  }

  void dispose() {
    _themeMode.dispose();
  }

  void setThemeMode(ThemeMode theme) {
    _themeMode.value = theme;
  }

  void copy(SettingsModel settings) {
    id = settings.id;
    splitLength = settings.splitLength;
    lapLength = settings.lapLength;
    dbSchemeVersion = settings.dbSchemeVersion;
    language = settings.language;
    mSecondRefresh = settings.mSecondRefresh;
    theme = settings.theme;
  }

  Future<void> update() async {
    SettingsManager.update(this);
  }
}
