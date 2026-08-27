import 'package:auto_injector/auto_injector.dart';

import '/core/bootstrap/bootstrap.dart';
import '/data/services/database/database_provider.dart';

void registerApplicationDependencies(AutoInjector injector) {
  injector
    ..add<DatabaseProvider>(DatabaseProvider.new)
    ..add<Bootstrap>(Bootstrap.new);
}
