import 'dart:ui';

import 'package:flutter/foundation.dart';

import '/core/result/command.dart';
import '/data/repositories/settings/settings_repository.dart';
import '/domain/common/settings/models/settings.dart';
import '/domain/common/training/units/distance_unit.dart';
import '/ui/app/app_appearance_state.dart';
import 'models/settings_form_data.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final AppAppearanceState _appearanceState;

  late final Command0<Settings> loadCommand;
  late final Command1<Unit, SettingsFormData?> saveCommand;

  SettingsFormData? _state;
  SettingsFormData? _pendingState;

  SettingsViewModel({
    required SettingsRepository repository,
    required AppAppearanceState appearanceState,
  })  : _repository = repository,
        _appearanceState = appearanceState {
    final current = repository.current;
    if (current != null) {
      _state = SettingsFormData.fromDomain(current);
    }
    loadCommand = Command0<Settings>(_load);
    saveCommand = Command1<Unit, SettingsFormData?>(_save);
  }

  SettingsFormData? get state => _state;

  @override
  void dispose() {
    loadCommand.dispose();
    saveCommand.dispose();
    super.dispose();
  }

  Future<void> load() => loadCommand.execute();

  Future<void> setSplitDistance(double value) =>
      _apply((state) => state.copyWith(splitDistance: value));

  Future<void> setLapDistance(double value) =>
      _apply((state) => state.copyWith(lapDistance: value));

  Future<void> setDistanceUnit(DistanceUnit value) =>
      _apply((state) => state.copyWith(distanceUnit: value));

  Future<void> setBrightness(Brightness value) =>
      _apply((state) => state.copyWith(brightness: value));

  Future<void> toggleBrightness() {
    final current = _state;
    if (current == null) {
      return saveCommand.execute(null);
    }

    final next = current.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return setBrightness(next);
  }

  Future<void> setContrast(AppContrast value) =>
      _apply((state) => state.copyWith(contrast: value));

  Future<void> setLocale(Locale value) =>
      _apply((state) => state.copyWith(locale: value));

  Future<void> setRefreshInterval(Duration value) =>
      _apply((state) => state.copyWith(refreshInterval: value));

  Future<Result<Settings>> _load() async {
    final result = await _repository.load();
    if (result.isFailure) return Failure(result.error!);

    final settings = result.value!;
    _state = SettingsFormData.fromDomain(settings);
    _appearanceState.synchronize(settings);
    notifyListeners();
    return Success(settings);
  }

  Future<void> markProtectedActionsHintSeen() {
    final current = _state;

    if (current == null || current.protectedActionsHintSeen) {
      return Future.value();
    }

    return _apply(
      (state) => state.copyWith(protectedActionsHintSeen: true),
    );
  }

  Future<void> _apply(
    SettingsFormData Function(SettingsFormData state) change,
  ) async {
    final current = _state;
    if (current == null) {
      await saveCommand.execute(null);
      return;
    }

    final candidate = change(current);
    final domain = candidate.toDomain();
    if (domain.isFailure) {
      await saveCommand.execute(candidate);
      return;
    }

    _state = candidate;
    _pendingState = candidate;
    _appearanceState.update(
      brightness: candidate.brightness,
      contrast: candidate.contrast,
      locale: candidate.locale,
    );
    notifyListeners();
    await saveCommand.execute(candidate);
  }

  Future<Result<Unit>> _save(SettingsFormData? requested) async {
    if (requested == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Settings must be loaded before they can be changed.',
        ),
      );
    }

    var next = _pendingState ?? requested;
    while (true) {
      _pendingState = null;
      final domain = next.toDomain();
      if (domain.isFailure) {
        _restoreLastPersisted();
        return Failure(domain.error!);
      }

      final result = await _repository.update(domain.value!);
      if (result.isFailure) {
        _restoreLastPersisted();
        return Failure(result.error!);
      }

      final pending = _pendingState;
      if (pending == null) return const Success(unit);
      next = pending;
    }
  }

  void _restoreLastPersisted() {
    _pendingState = null;
    final persisted = _repository.current;
    if (persisted == null) return;
    _state = SettingsFormData.fromDomain(persisted);
    _appearanceState.synchronize(persisted);
    notifyListeners();
  }
}
