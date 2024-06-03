import 'package:sqflite/sqflite.dart';

import '../constants/table_sql_scripts.dart';

sealed class DatabaseCreateTable {
  DatabaseCreateTable._();

  static void settingsTable(Batch batch) {
    batch.execute(createSettingsSQL);
  }

  static void userTable(Batch batch) {
    batch.execute(createUserTableSQL);
    batch.execute(createUserNameIndexSQL);
  }

  static void trainingTable(Batch batch) {
    batch.execute(createTrainingTableSQL);
    batch.execute(createTrainingDateIndexSQL);
  }

  static void historyTable(Batch batch) {
    batch.execute(createHistoryTableSQL);
    batch.execute(createHistoryTrainingIndexSQL);
  }
}
