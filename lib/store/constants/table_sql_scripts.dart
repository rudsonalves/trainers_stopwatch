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
    ' $settingsMSecondRefresh INTEGER DEFAULT 66'
    ')';

const createAthleteTableSQL = 'CREATE TABLE IF NOT EXISTS $athleteTable ('
    ' $athleteId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $athleteName TEXT NOT NULL,'
    ' $athleteEmail TEXT NOT NULL,'
    ' $athletePhone TEXT,'
    ' $athletePhoto TEXT'
    ')';

const createAthleteNameIndexSQL = 'CREATE INDEX IF NOT EXISTS $athleteNameIndex'
    ' ON $athleteTable ($athleteName)';

const createTrainingTableSQL = 'CREATE TABLE IF NOT EXISTS $trainingTable ('
    ' $trainingId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $trainingAthleteId INTEGER NOT NULL,'
    ' $trainingDate INTEGER NOT NULL,'
    ' $trainingComments TEXT,'
    ' $trainingSplitLength REAL NOT NULL,'
    ' $trainingLapLength REAL NOT NULL,'
    ' $trainingMaxlaps INTEGER,'
    ' $trainingDistanceUnit CHAR(5),'
    ' $trainingSpeedUnit CHAR(5),'
    ' FOREIGN KEY ($trainingAthleteId)'
    '   REFERENCES $athleteTable ($athleteId)'
    '   ON DELETE CASCADE'
    ')';

const createTrainingDateIndexSQL =
    'CREATE INDEX IF NOT EXISTS $trainingDateIndex'
    ' ON $trainingTable ($trainingDate)';

const createHistoryTableSQL = 'CREATE TABLE IF NOT EXISTS $historyTable ('
    ' $historyId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
    ' $historyTrainingId INTEGER NOT NULL,'
    ' $historyLap INTEGER,'
    ' $historySplit INTEGER NOT NULL,'
    ' $historyDuration INTEGER NOT NULL,'
    ' $historyComments TEXT,'
    ' FOREIGN KEY ($historyTrainingId)'
    '   REFERENCES $trainingTable ($trainingId)'
    '   ON DELETE CASCADE'
    ')';

const createHistoryTrainingIndexSQL =
    'CREATE INDEX IF NOT EXISTS $historyTrainingIndex'
    ' ON $historyTable ($historyTrainingId)';
