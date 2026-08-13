import 'package:auto_injector/auto_injector.dart';

import '../../common/singletons/app_settings.dart';
import '../../store/database/database_manager.dart';
import '../../store/database/database_provider.dart';
import '../bootstrap/bootstrap.dart';

final injector = AutoInjector();
bool _initialized = false;

void setupDependencies() {
  if (_initialized) return;

  injector
    ..addInstance<DatabaseManager>(DatabaseManager.instance)
    ..addInstance<AppSettings>(AppSettings.instance)
    ..add<DatabaseProvider>(DatabaseProvider.new)
    ..add<Bootstrap>(Bootstrap.new)
    ..commit();

  _initialized = true;
}
