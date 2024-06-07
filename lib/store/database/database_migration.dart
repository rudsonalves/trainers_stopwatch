import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../manager/settings_manager.dart';
import '../../common/models/settings_model.dart';
import '../constants/migration_sql_scripts.dart';

class DatabaseMigration {
  DatabaseMigration._();

  /// Applies migration scripts to the database batch.
  ///
  /// This method iterates through the migration scripts from the current
  /// database version up to the target version, executing each script in
  /// sequence to update the database schema.
  ///
  /// - Parameters:
  ///   - batch: The database batch on which to execute the migration scripts.
  ///   - currentVersion: The current version of the database schema.
  ///   - targetVersion: The target version to which the database should
  ///     be migrated.
  static Future<void> applyMigrations({
    required Database db,
    required SettingsModel settings,
  }) async {
    await db.execute('PRAGMA foreign_keys=off');
    for (var version = settings.dbSchemeVersion + 1;
        version <= MigrationSqlScripts.schemeVersion;
        version++) {
      log('Database migrating to version: $version');
      final batch = db.batch();
      final scripts = MigrationSqlScripts.sqlMigrationsScripts[version];
      if (scripts != null) {
        for (final script in scripts) {
          batch.execute(script);
        }
      }
      await batch.commit(noResult: true);
      settings.dbSchemeVersion = MigrationSqlScripts.schemeVersion;
      await SettingsManager.update(settings);
    }
    await db.execute('PRAGMA foreign_keys=on');
  }
}
