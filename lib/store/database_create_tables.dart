import 'package:sqflite/sqflite.dart';

import 'constants/table_sql_scripts.dart';

sealed class DatabaseCreateTable {
  DatabaseCreateTable._();

  static void athleteTable(Batch batch) {
    batch.execute(createAthleteTableSQL);
    batch.execute(createAthleteNameIndexSQL);
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
