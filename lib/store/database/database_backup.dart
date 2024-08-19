import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/table_attributes.dart';
import 'database_manager.dart';

class DatabaseBackup {
  DatabaseBackup._();

  static final _databaseManager = DatabaseManager.instance;

  /// Restores the database from a backup located at [newDbPath].
  ///
  /// Returns `true` if the restoration is successful, `false` otherwise.
  static Future<bool> restoreDatabase(String newDBPath) async {
    final database = await _databaseManager.database;

    final Directory directory = await getApplicationDocumentsDirectory();
    final String originalPath = join(directory.path, dbName);
    final backupPath = join(directory.path, '$dbName.bkp');

    try {
      final File backupFile = File(backupPath);
      // Checks whether a backup file exists in backup path. If exists,
      // remove it.
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      // Copy original file to backup path
      final File originalFile = File(originalPath);
      await originalFile.copy(backupPath);

      // Close database before replace it
      await _databaseManager.close();
      // Remove original database
      await originalFile.delete();

      // Replace original database by new one, and open a new database
      await File(newDBPath).copy(originalPath);
      await _databaseManager.database;

      // remove backup database
      await backupFile.delete();

      return true;
    } catch (err) {
      final message = 'DatabaseBackup.restoreDatabase: $err';
      log(message);

      // get backup file
      final File backupFile = File(backupPath);
      if (await backupFile.exists()) {
        // Check if database is open and close it
        if (database.isOpen) await _databaseManager.close();
        // Copy backup database to original path
        await backupFile.copy(originalPath);
        // Reopen database file
        await _databaseManager.database;
        // Remove backup file
        await backupFile.delete();
      }

      return false;
    }
  }

  /// Creates a backup of the current database.
  ///
  /// Optionally, a [destinyDir] can be specified to store the backup.
  /// Returns the path to the backup file if successful, `null` otherwise.
  static Future<String?> backupDatabase([String? destinyDir]) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String dbPath = join(dir.path, dbName);
      final strDate = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());

      String dbBackupPath = (destinyDir == null)
          ? join(dir.path, '$dbName.bkp')
          : join(dir.path, '$dbName.bkp_$strDate');

      final dbBackupFile = File(dbBackupPath);
      if (await dbBackupFile.exists()) {
        await dbBackupFile.delete();
      }

      final File dbFile = File(dbPath);
      await dbFile.copy(dbBackupPath);

      return dbBackupPath;
    } catch (err) {
      final message = 'DatabaseBackup.backupDatabase: $err';
      log(message);
      return null;
    }
  }
}
