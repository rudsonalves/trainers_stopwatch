import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
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
        ..execute(createHistoryTrainingIndexSQL);

      await batch.commit(noResult: true);
    } catch (error, stackTrace) {
      throw AppError(
        code: AppErrorCode.databaseCreationFailed,
        message: 'Unable to create the application database.',
        details: (error: error, stackTrace: stackTrace),
      );
    }
  }
}
