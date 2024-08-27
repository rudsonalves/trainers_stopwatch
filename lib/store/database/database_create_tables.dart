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
