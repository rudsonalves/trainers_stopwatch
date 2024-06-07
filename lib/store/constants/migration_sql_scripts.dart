import 'table_attributes.dart';

class MigrationSqlScripts {
  MigrationSqlScripts._();

  /// Database Scheme Version declarations
  ///
  /// This is the database scheme current version. To futures upgrades
  /// in database increment this value and add a new update script in
  /// _migrationScripts Map.
  static const schemeVersion = 1005;

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
  };
}
