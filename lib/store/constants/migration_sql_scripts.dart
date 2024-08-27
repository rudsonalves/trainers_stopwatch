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

import 'table_attributes.dart';

class MigrationSqlScripts {
  MigrationSqlScripts._();

  /// Database Scheme Version declarations
  ///
  /// This is the database scheme current version. To futures upgrades
  /// in database increment this value and add a new update script in
  /// _migrationScripts Map.
  static const schemeVersion = 1006;

  // Retrieves the database schema version in a readable format (e.g., "1.0.07").
  static String get dbSchemeVersion {
    String version = schemeVersion.toString();
    int length = version.length;
    return '${version.substring(0, length - 3)}.'
        '${version.substring(length - 3, length - 2)}.'
        '${version.substring(length - 2)}';
  }

  /// This Map contains the database migration scripts. The last index of this
  /// Map must be equal to the current version of the database.
  static const Map<int, List<String>> sqlMigrationsScripts = {
    1000: [],
    1001: [
      'ALTER TABLE $settingsTable ADD COLUMN $settingsSplitLength REAL DEFAULT 200',
      'ALTER TABLE $settingsTable ADD COLUMN $settingsLapLength REAL DEFAULT 1000',
    ],
    1002: [
      'ALTER TABLE $trainingTable ADD COLUMN $trainingMaxlaps INTEGER',
    ],
    1003: [
      'ALTER TABLE $settingsTable ADD COLUMN $settingsLengthUnit CHAR(3) DEFAULT "m"',
    ],
    1004: [
      'ALTER TABLE $settingsTable ADD COLUMN $settingsContrast CHAR(6) DEFAULT "standard"',
    ],
    1005: [
      'ALTER TABLE $settingsTable ADD COLUMN $settingsShowTutorial INTEGER DEFAULT 1',
    ],
    1006: [
      'CREATE TABLE IF NOT EXISTS ${historyTable}_new ('
          ' $historyId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          ' $historyTrainingId INTEGER NOT NULL,'
          ' $historyDuration INTEGER NOT NULL,'
          ' $historyComments TEXT,'
          ' FOREIGN KEY ($historyTrainingId)'
          '   REFERENCES $trainingTable ($trainingId)'
          '   ON DELETE CASCADE'
          ')',
      'INSERT INTO ${historyTable}_new ('
          ' $historyId,'
          ' $historyTrainingId,'
          ' $historyDuration,'
          ' $historyComments'
          ')'
          'SELECT'
          ' $historyId, $historyTrainingId, $historyDuration, $historyComments'
          ' FROM $historyTable',
      'DROP TABLE $historyTable',
      'ALTER TABLE ${historyTable}_new RENAME TO $historyTable',
    ],
  };
}
