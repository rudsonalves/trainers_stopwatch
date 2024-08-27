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

const createSettingsSQL = 'CREATE TABLE IF NOT EXISTS $settingsTable ('
    ' $settingsId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $settingsSplitLength REAL DEFAULT 200,'
    ' $settingsLapLength REAL DEFAULT 1000,'
    ' $settingsLengthUnit CHAR(3) DEFAULT "m",'
    ' $settingsDatabaseSchemeVersion INTEGER NOT NULL,'
    ' $settingsBrightness CHAR(6) DEFAULT "system",'
    ' $settingsContrast CHAR(6) DEFAULT "standard",'
    ' $settingsLanguage CHAR(5) DEFAULT "en_US",'
    ' $settingsMSecondRefresh INTEGER DEFAULT 66,'
    ' $settingsShowTutorial INTEGER DEFAULT 1'
    ')';

const createUserTableSQL = 'CREATE TABLE IF NOT EXISTS $userTable ('
    ' $userId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $userName TEXT NOT NULL,'
    ' $userEmail TEXT NOT NULL,'
    ' $userPhone TEXT,'
    ' $userPhoto TEXT'
    ')';

const createUserNameIndexSQL = 'CREATE INDEX IF NOT EXISTS $userNameIndex'
    ' ON $userTable ($userName)';

const createTrainingTableSQL = 'CREATE TABLE IF NOT EXISTS $trainingTable ('
    ' $trainingId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $trainingUserId INTEGER NOT NULL,'
    ' $trainingDate INTEGER NOT NULL,'
    ' $trainingComments TEXT,'
    ' $trainingSplitLength REAL NOT NULL,'
    ' $trainingLapLength REAL NOT NULL,'
    ' $trainingMaxlaps INTEGER,'
    ' $trainingDistanceUnit CHAR(5),'
    ' $trainingSpeedUnit CHAR(5),'
    ' FOREIGN KEY ($trainingUserId)'
    '   REFERENCES $userTable ($userId)'
    '   ON DELETE CASCADE'
    ')';

const createTrainingDateIndexSQL =
    'CREATE INDEX IF NOT EXISTS $trainingDateIndex'
    ' ON $trainingTable ($trainingDate)';

const createHistoryTableSQL = 'CREATE TABLE IF NOT EXISTS $historyTable ('
    ' $historyId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $historyTrainingId INTEGER NOT NULL,'
    ' $historyDuration INTEGER NOT NULL,'
    ' $historyComments TEXT,'
    ' FOREIGN KEY ($historyTrainingId)'
    '   REFERENCES $trainingTable ($trainingId)'
    '   ON DELETE CASCADE'
    ')';

const createHistoryTrainingIndexSQL =
    'CREATE INDEX IF NOT EXISTS $historyTrainingIndex'
    ' ON $historyTable ($historyTrainingId)';

const getUserImagesListSQL = 'SELECT $userPhoto FROM $userTable';
