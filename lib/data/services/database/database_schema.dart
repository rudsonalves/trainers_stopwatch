import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
import 'table_attributes.dart';
import 'table_sql_scripts.dart';

class DatabaseSchema {
  const DatabaseSchema();

  Future<void> create(Database database, int version) async {
    try {
      final batch = database.batch()
        ..execute(createSettingsSQL)
        ..execute(createUserTableSQL)
        ..execute(createUserNameIndexSQL)
        ..execute(createTrainingTableSQL)
        ..execute(createTrainingDateIndexSQL)
        ..execute(createHistoryTableSQL)
        ..execute(createHistoryTrainingIndexSQL)
        ..execute(createHistorySnapshotIdentityIndexSQL);

      await batch.commit(noResult: true);
    } catch (error, stackTrace) {
      throw AppError(
        code: AppErrorCode.databaseCreationFailed,
        message: 'Unable to create the application database.',
        details: (error: error, stackTrace: stackTrace),
      );
    }
  }

  Future<void> upgrade(
      Database database, int oldVersion, int newVersion) async {
    if (oldVersion != idempotentHistoryMigrationVersion ||
        newVersion != dbVersion) {
      throw AppError(
        code: AppErrorCode.migrationFailed,
        message: 'Unsupported application database migration.',
        details: (oldVersion: oldVersion, newVersion: newVersion),
      );
    }

    try {
      final batch = database.batch()
        ..execute(addHistorySnapshotRevisionSQL)
        ..execute(addHistorySnapshotTypeSQL)
        ..execute(createHistorySnapshotIdentityIndexSQL);
      await batch.commit(noResult: true);
    } catch (error, stackTrace) {
      throw AppError(
        code: AppErrorCode.migrationFailed,
        message: 'Unable to migrate the application database.',
        details: (error: error, stackTrace: stackTrace),
      );
    }
  }
}
