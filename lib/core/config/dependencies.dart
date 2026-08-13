import 'package:auto_injector/auto_injector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/singletons/app_settings.dart';
import '../../data/services/database/database_backup_service.dart';
import '../../data/services/database/database_schema.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/settings/settings_mapper.dart';
import '../../data/services/settings/settings_service.dart';
import '../../store/database/database_manager.dart';
import '../../store/database/database_provider.dart';
import '../bootstrap/bootstrap.dart';

final injector = AutoInjector();
bool _initialized = false;

void setupDependencies() {
  if (_initialized) return;

  injector
    ..addInstance<DatabaseSchema>(const DatabaseSchema())
    ..addInstance<DatabaseBackupService>(
      DatabaseBackupService(clock: DateTime.now),
    )
    ..addInstance<SettingsMapper>(const SettingsMapper())
    ..addSingleton<DatabaseService>(
      () => DatabaseService(
        databaseDirectoryPath: () async =>
            (await getApplicationDocumentsDirectory()).path,
        openDatabase: (path, options) =>
            databaseFactory.openDatabase(path, options: options),
        databaseExists: (path) => databaseFactory.databaseExists(path),
        readDatabaseVersion: (path) async {
          final database = await databaseFactory.openDatabase(
            path,
            options: OpenDatabaseOptions(
              readOnly: true,
              singleInstance: false,
            ),
          );
          try {
            return await database.getVersion();
          } finally {
            await database.close();
          }
        },
        deleteDatabase: (path) => databaseFactory.deleteDatabase(path),
        backupService: injector.get<DatabaseBackupService>(),
        schema: injector.get<DatabaseSchema>(),
      ),
    )
    ..add<SettingsService>(SettingsService.new)
    ..addInstance<DatabaseManager>(DatabaseManager.instance)
    ..addInstance<AppSettings>(AppSettings.instance)
    ..add<DatabaseProvider>(DatabaseProvider.new)
    ..add<Bootstrap>(Bootstrap.new)
    ..commit();

  _initialized = true;
}
