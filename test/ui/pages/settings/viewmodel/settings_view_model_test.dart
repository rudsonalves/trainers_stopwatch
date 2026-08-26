import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/adapters/legacy_settings_sink.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/settings/settings_repository.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/ui/app/app_appearance_state.dart';
import 'package:trainers_stopwatch/ui/pages/settings/viewmodel/settings_view_model.dart';

class _SettingsRepositoryFake implements SettingsRepository {
  Settings? stored;
  AppError? loadError;
  AppError? updateError;
  Completer<void>? blockNextUpdate;
  final updates = <Settings>[];

  @override
  Settings? get current => stored;

  @override
  AsyncResult<Settings> load() async {
    final error = loadError;
    if (error != null) return Failure(error);
    return Success(stored!);
  }

  @override
  AsyncResult<Unit> update(Settings settings) async {
    updates.add(settings);
    final blocker = blockNextUpdate;
    blockNextUpdate = null;
    if (blocker != null) await blocker.future;

    final error = updateError;
    if (error != null) return Failure(error);
    stored = settings;
    return const Success(unit);
  }
}

class _LegacySettingsSinkFake implements LegacySettingsSink {
  final synchronized = <Settings>[];

  @override
  void synchronize(Settings settings) => synchronized.add(settings);
}

void main() {
  late Settings initial;
  late _SettingsRepositoryFake repository;
  late AppAppearanceState appearanceState;
  late _LegacySettingsSinkFake legacySettings;
  late SettingsViewModel viewModel;

  setUp(() {
    initial = Settings.create(id: 1).value!;
    repository = _SettingsRepositoryFake()..stored = initial;
    appearanceState = AppAppearanceState(settings: initial);
    legacySettings = _LegacySettingsSinkFake();
    viewModel = SettingsViewModel(
      repository: repository,
      appearanceState: appearanceState,
      legacySettings: legacySettings,
    );
  });

  tearDown(() {
    viewModel.dispose();
    appearanceState.dispose();
  });

  test('loads domain settings and synchronizes global presentation', () async {
    repository.stored = Settings.create(
      id: 1,
      brightness: BrightnessPreference.light,
      contrast: ContrastPreference.high,
      language: const LanguagePreference('pt', 'BR'),
    ).value!;

    await viewModel.load();

    expect(viewModel.loadCommand.isSuccess, isTrue);
    expect(viewModel.state!.brightness, Brightness.light);
    expect(appearanceState.brightness, Brightness.light);
    expect(legacySettings.synchronized, [repository.stored]);
    expect(appearanceState.contrast, AppContrast.high);
    expect(appearanceState.locale, const Locale('pt', 'BR'));
  });

  test('exposes a controlled load failure without changing state', () async {
    const error = AppError(
      code: AppErrorCode.storageReadFailed,
      message: 'read failed',
    );
    repository.loadError = error;

    await viewModel.load();

    expect(viewModel.loadCommand.isFailure, isTrue);
    expect(viewModel.loadCommand.error, same(error));
    expect(viewModel.state!.toDomain().value, initial);
  });

  test('persists a valid edit immediately and updates global state', () async {
    await viewModel.setBrightness(Brightness.light);

    expect(viewModel.saveCommand.isSuccess, isTrue);
    expect(repository.updates, hasLength(1));
    expect(repository.stored!.brightness, BrightnessPreference.light);
    expect(appearanceState.brightness, Brightness.light);
    expect(legacySettings.synchronized, [repository.stored]);
  });

  test('toggles brightness and persists each new value', () async {
    expect(viewModel.state!.brightness, Brightness.dark);

    await viewModel.toggleBrightness();

    expect(viewModel.state!.brightness, Brightness.light);
    expect(appearanceState.brightness, Brightness.light);
    expect(repository.stored!.brightness, BrightnessPreference.light);

    await viewModel.toggleBrightness();

    expect(viewModel.state!.brightness, Brightness.dark);
    expect(appearanceState.brightness, Brightness.dark);
    expect(repository.stored!.brightness, BrightnessPreference.dark);
    expect(repository.updates, hasLength(2));
    expect(legacySettings.synchronized, repository.updates);
  });

  test('persists contrast and locale and synchronizes both consumers',
      () async {
    await viewModel.setContrast(AppContrast.medium);
    await viewModel.setLocale(const Locale('pt', 'BR'));

    expect(repository.stored!.contrast, ContrastPreference.medium);
    expect(
      repository.stored!.language,
      const LanguagePreference('pt', 'BR'),
    );
    expect(appearanceState.contrast, AppContrast.medium);
    expect(appearanceState.locale, const Locale('pt', 'BR'));
    expect(legacySettings.synchronized, hasLength(2));
    expect(legacySettings.synchronized.last, repository.stored);
  });

  test('persists distances, their common unit and refresh interval', () async {
    await viewModel.setSplitDistance(250);
    await viewModel.setLapDistance(1250);
    await viewModel.setDistanceUnit(DistanceUnit.yard);
    await viewModel.setRefreshInterval(const Duration(milliseconds: 100));

    expect(repository.stored!.splitDistance.value, 250);
    expect(repository.stored!.lapDistance.value, 1250);
    expect(repository.stored!.splitDistance.unit, DistanceUnit.yard);
    expect(repository.stored!.lapDistance.unit, DistanceUnit.yard);
    expect(
      repository.stored!.refreshInterval,
      const Duration(milliseconds: 100),
    );
  });

  test('queues the latest valid edit while persistence is running', () async {
    final blocker = Completer<void>();
    repository.blockNextUpdate = blocker;

    final first = viewModel.setBrightness(Brightness.light);
    await Future<void>.delayed(Duration.zero);
    final second = viewModel.setContrast(AppContrast.high);
    blocker.complete();
    await Future.wait([first, second]);

    expect(repository.updates, hasLength(2));
    expect(repository.updates.first.brightness, BrightnessPreference.light);
    expect(repository.updates.last.brightness, BrightnessPreference.light);
    expect(repository.updates.last.contrast, ContrastPreference.high);
    expect(repository.stored, repository.updates.last);
    expect(legacySettings.synchronized, repository.updates);
  });

  test('rolls presentation back when immediate persistence fails', () async {
    const error = AppError(
      code: AppErrorCode.storageWriteFailed,
      message: 'write failed',
    );
    repository.updateError = error;

    await viewModel.setLocale(const Locale('pt', 'BR'));

    expect(viewModel.saveCommand.isFailure, isTrue);
    expect(viewModel.saveCommand.error, same(error));
    expect(viewModel.state!.locale, const Locale('en', 'US'));
    expect(appearanceState.locale, const Locale('en', 'US'));
    expect(repository.current, initial);
    expect(legacySettings.synchronized, isEmpty);
  });

  test('rejects invalid edits without changing presentation state', () async {
    await viewModel.setSplitDistance(0);

    expect(viewModel.saveCommand.isFailure, isTrue);
    expect(viewModel.saveCommand.error!.code, AppErrorCode.invalidData);
    expect(viewModel.state!.splitDistance, 200);
    expect(repository.updates, isEmpty);
  });
}
