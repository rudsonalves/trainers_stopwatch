import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../manager/settings_manager.dart';
import '../../models/settings_model.dart';

const int maxFocusNode = 17;

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

  late final Signal<Brightness> _brightness;
  late final Signal<Contrast> _contrast;

  bool tutorialOn = false;
  int tutorialId = 0;

  bool isTutorial(int athleteId) {
    return tutorialOn && tutorialId == athleteId;
  }

  String get imagePath => _imagePath;
  Signal<Brightness> get brightnessMode => _brightness;
  Signal<Contrast> get contrastMode => _contrast;

  Future<void> init() async {
    // Load app Settings
    final settings = await SettingsManager.query();
    copy(settings);
    // Update Brightness & Contrast
    _brightness = signal<Brightness>(settings.brightness);
    _contrast = signal<Contrast>(settings.contrast);

    // Start app paths
    _appDocDir = await getApplicationDocumentsDirectory();
    _imagePath = '${_appDocDir.path}/athletes_images';
    final athletesImageDir = Directory(_imagePath);
    // Create athletesImageDir in necessary
    if (!await athletesImageDir.exists()) {
      await athletesImageDir.create(recursive: true);
    }
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

  void copy(SettingsModel settings) {
    id = settings.id;
    splitLength = settings.splitLength;
    lapLength = settings.lapLength;
    dbSchemeVersion = settings.dbSchemeVersion;
    language = settings.language;
    mSecondRefresh = settings.mSecondRefresh;
    brightness = settings.brightness;
  }

  Future<void> update() async {
    SettingsManager.update(this);
  }
}
