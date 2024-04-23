import 'dart:developer';

import 'package:trainers_stopwatch/manager/settings_manager.dart';

import '../constants/migration_sql_scripts.dart';
import 'database_backup.dart';
import 'database_manager.dart';
import 'database_migration.dart';

class DatabaseProvider {
  final _databaseManager = DatabaseManager.instance;

  Future init() async {
    final database = await _databaseManager.database;
    final settings = await SettingsManager.query();

    final backupDatabase = await DatabaseBackup.backupDatabase();
    try {
      if (MigrationSqlScripts.schemeVersion > settings.dbSchemeVersion) {
        await DatabaseMigration.applyMigrations(
          db: database,
          settings: settings,
        );
      }
    } catch (err) {
      if (backupDatabase != null) {
        await DatabaseBackup.restoreDatabase(backupDatabase);
      }
      final message = 'DatabaseProvider.init: $err';
      log(message);
    }
  }
}
