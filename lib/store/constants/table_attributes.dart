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

const dbName = 'stopwatch.db';
const dbVersion = 1;

const settingsTable = 'settingsTable';
const settingsId = 'id';
const settingsSplitLength = 'splitLength';
const settingsLapLength = 'lapLength';
const settingsLengthUnit = 'lengthUnit';
const settingsDatabaseSchemeVersion = 'dbSchemeVersion';
const settingsBrightness = 'brightness';
const settingsContrast = 'contrast';
const settingsLanguage = 'language';
const settingsMSecondRefresh = 'mSecondRefresh';
const settingsShowTutorial = 'showTutorial';

const userTable = 'userTable';
const userNameIndex = 'userNameIndex';
const userId = 'id';
const userName = 'name';
const userEmail = 'email';
const userPhone = 'phone';
const userPhoto = 'photo';

const trainingTable = 'trainingTable';
const trainingDateIndex = 'trainingDateIndex';
const trainingId = 'id';
const trainingUserId = 'userId';
const trainingDate = 'date';
const trainingComments = 'comments';
const trainingSplitLength = 'splitLength';
const trainingLapLength = 'lapLength';
const trainingMaxlaps = 'maxlaps';
const trainingDistanceUnit = 'distanceUnit';
const trainingSpeedUnit = 'speedUnit';

const historyTable = 'historyTable';
const historyTrainingIndex = 'historyTrainingIndex';
const historyId = 'id';
const historyTrainingId = 'trainingId';
const historyDuration = 'duration';
const historyComments = 'comments';
