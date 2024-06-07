import '../../common/models/settings_model.dart';

abstract class AbstractSettingsRepositoy {
  Future<int> insert(SettingsModel settings);
  Future<SettingsModel?> query();
  Future<int> update(SettingsModel settings);
}
