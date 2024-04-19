import 'dart:developer';

import 'package:sqflite/sqflite.dart';

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
    required int currentVersion,
    required int targetVersion,
  }) async {
    await db.execute('PRAGMA foreign_keys=off');
    for (var version = currentVersion + 1;
        version <= targetVersion;
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
    }
    await db.execute('PRAGMA foreign_keys=on');
  }
}
