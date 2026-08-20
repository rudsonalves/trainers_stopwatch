import '/core/result/result.dart';
import '/data/services/settings/settings_service.dart';
import '/domain/common/settings/models/settings.dart';
import 'settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsService _service;
  Settings? _current;

  SettingsRepositoryImpl({required SettingsService service})
      : _service = service;

  @override
  Settings? get current => _current;

  @override
  AsyncResult<Settings> load() async {
    final readResult = await _service.read();
    if (readResult.isFailure) return Failure(readResult.error!);

    final settings = switch (readResult.value!) {
      SettingsFound(:final settings) => settings,
      SettingsMissing() => null,
    };
    if (settings != null) {
      _current = settings;
      return Success(settings);
    }

    final defaults = Settings.create();
    if (defaults.isFailure) return Failure(defaults.error!);
    final insertResult = await _service.insert(defaults.value!);
    if (insertResult.isFailure) return Failure(insertResult.error!);
    _current = insertResult.value!;
    return Success(_current!);
  }

  @override
  AsyncResult<Unit> update(Settings settings) async {
    final result = await _service.update(settings);
    if (result.isFailure) return Failure(result.error!);
    _current = settings;
    return const Success(unit);
  }
}
