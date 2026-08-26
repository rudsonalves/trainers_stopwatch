import 'package:auto_injector/auto_injector.dart';

import '/common/adapters/legacy_settings_sink.dart';
import '/common/singletons/app_settings.dart';
import '/core/bootstrap/bootstrap.dart';
import '/data/services/database/database_provider.dart';

void registerApplicationDependencies(AutoInjector injector) {
  injector
    ..addInstance<AppSettings>(AppSettings.instance)
    ..addInstance<LegacySettingsSink>(AppSettings.instance)
    ..add<DatabaseProvider>(DatabaseProvider.new)
    ..add<Bootstrap>(Bootstrap.new);
}
