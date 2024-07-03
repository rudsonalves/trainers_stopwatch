import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../manager/settings_manager.dart';
import '../models/settings_model.dart';

const int maxFocusNode = 29;

class AppSettings extends SettingsModel {
  AppSettings._();
  static final _instance = AppSettings._();
  static AppSettings get instance => _instance;
  final focusNodes = List<FocusNode>.generate(
    maxFocusNode,
    (index) => FocusNode(debugLabel: 'FocusNode id $index'),
    growable: true,
  );

  late final String _imagePath;
  late final Directory _appDocDir;

  late final ValueNotifier<Brightness> _brightness;
  late final ValueNotifier<Contrast> _contrast;

  bool tutorialOn = false;
  int tutorialId = 0;

  bool isTutorial(int userId) {
    return tutorialOn && tutorialId == userId;
  }

  String get imagePath => _imagePath;
  ValueNotifier<Brightness> get brightnessMode => _brightness;
  ValueNotifier<Contrast> get contrastMode => _contrast;

  Future<void> init() async {
    // Load app Settings
    final settings = await SettingsManager.query();
    copy(settings);
    // Update Brightness & Contrast
    _brightness = ValueNotifier<Brightness>(settings.brightness);
    _contrast = ValueNotifier<Contrast>(settings.contrast);

    // Start app paths
    _appDocDir = await getApplicationDocumentsDirectory();
    _imagePath = '${_appDocDir.path}/users_images';
    final usersImageDir = Directory(_imagePath);
    // Create usersImageDir in necessary
    if (!await usersImageDir.exists()) {
      await usersImageDir.create(recursive: true);
    }
  }

  void disableTutorial() {
    tutorialOn = false;
    showTutorial = false;
    update();
  }

  void setContrast(Contrast contrast) {
    _contrast.value = contrast;
    this.contrast = contrast;
    update();
  }

  void toggleBrightnessMode() {
    _brightness.value = _brightness.value == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    brightness = _brightness.value;
    update();
  }

  void dispose() {
    _brightness.dispose();
    _contrast.dispose();
    for (var focus in focusNodes) {
      focus.dispose();
    }
  }

  void setBrightnessMode(Brightness brightness) {
    _brightness.value = brightness;
  }

  Future<void> update() async {
    SettingsManager.update(this);
  }
}
