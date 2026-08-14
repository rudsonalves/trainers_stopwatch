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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/repositories/settings/settings_repository.dart';
import '../../domain/common/settings/models/settings.dart';
import '../../ui/app/app_appearance_state.dart';
import '../adapters/legacy_settings_sink.dart';
import '../adapters/settings_domain_adapter.dart';
import '../constants.dart';
import '../models/settings_model.dart';

/// Temporary adapter for consumers migrated in backlogs 005, 007 and 010.
class AppSettings extends SettingsModel implements LegacySettingsSink {
  AppSettings._();
  static final _instance = AppSettings._();
  static AppSettings get instance => _instance;

  late final String _imagePath;
  late final Directory _appDocDir;
  late final SettingsRepository _repository;
  late final AppAppearanceState _appearanceState;

  final ValueNotifier<Brightness> _brightness = ValueNotifier(Brightness.dark);

  String get imagePath => _imagePath;
  ValueNotifier<Brightness> get brightnessMode => _brightness;

  Future<void> init(
    SettingsRepository repository,
    AppAppearanceState appearanceState,
  ) async {
    _repository = repository;
    _appearanceState = appearanceState;
    // Load app Settings
    final result = await _repository.load();
    if (result.isFailure) throw result.error!;
    synchronize(result.value!);

    // Start app paths
    _appDocDir = await getApplicationDocumentsDirectory();
    _imagePath = '${_appDocDir.path}/$usersImages';
    final usersImageDir = Directory(_imagePath);
    // Create usersImageDir in necessary
    if (!await usersImageDir.exists()) {
      await usersImageDir.create(recursive: true);
    }
  }

  Future<void> toggleBrightnessMode() async {
    final nextBrightness = _brightness.value == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    final legacy = SettingsModel(
      id: id,
      splitLength: splitLength,
      lapLength: lapLength,
      lengthUnit: lengthUnit,
      brightness: nextBrightness,
      contrast: contrast,
      language: language,
      mSecondRefresh: mSecondRefresh,
    );
    final settings = legacy.toDomain();
    if (settings.isFailure) throw settings.error!;
    final result = await _repository.update(settings.value!);
    if (result.isFailure) throw result.error!;
    synchronize(settings.value!);
    _appearanceState.synchronize(settings.value!);
  }

  void dispose() {
    _brightness.dispose();
  }

  @override
  void synchronize(Settings settings) {
    final legacy = settings.toLegacy();
    copy(legacy);
    if (_brightness.value != legacy.brightness) {
      _brightness.value = legacy.brightness;
    }
  }
}
