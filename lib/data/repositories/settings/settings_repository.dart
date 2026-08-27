import '/core/result/result.dart';
import '/domain/common/settings/models/settings.dart';

abstract interface class SettingsRepository {
  Settings? get current;

  AsyncResult<Settings> load();
  AsyncResult<Unit> update(Settings settings);
}
