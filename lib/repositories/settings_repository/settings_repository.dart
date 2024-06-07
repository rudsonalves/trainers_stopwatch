import '../../common/models/settings_model.dart';
import '../../store/stores/settings_store.dart';
import 'abstract_settings_repository.dart';

class SettingsRepository implements AbstractSettingsRepositoy {
  final _store = SettingsStore();

  @override
  Future<int> insert(SettingsModel settings) async {
    final id = await _store.insert(settings.toMap());
    settings.id = id;

    return id;
  }

  @override
  Future<SettingsModel?> query() async {
    final map = await _store.query();
    if (map == null) return null;
    final settings = SettingsModel.fromMap(map);
    return settings;
  }

  @override
  Future<int> update(SettingsModel settings) async {
    final result = await _store.update(settings.toMap());
    return result;
  }
}
