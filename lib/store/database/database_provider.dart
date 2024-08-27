// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:developer';

import '../../common/singletons/app_settings.dart';
import '../constants/migration_sql_scripts.dart';
import 'database_backup.dart';
import 'database_manager.dart';
import 'database_migration.dart';

class DatabaseProvider {
  final _databaseManager = DatabaseManager.instance;

  Future init() async {
    final database = await _databaseManager.database;
    final app = AppSettings.instance;
    await app.init();
    // final settings = await SettingsManager.query();

    final backupDatabase = await DatabaseBackup.backupDatabase();
    try {
      if (MigrationSqlScripts.schemeVersion > app.dbSchemeVersion) {
        await DatabaseMigration.applyMigrations(
          db: database,
          settings: app,
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
