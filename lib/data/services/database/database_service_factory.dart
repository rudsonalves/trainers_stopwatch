import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_backup_service.dart';
import 'database_schema.dart';
import 'database_service.dart';

DatabaseService createDatabaseService({
  required DatabaseBackupService backupService,
  required DatabaseSchema schema,
}) =>
    DatabaseService(
      databaseDirectoryPath: () async =>
          (await getApplicationDocumentsDirectory()).path,
      openDatabase: (path, options) =>
          databaseFactory.openDatabase(path, options: options),
      databaseExists: (path) => databaseFactory.databaseExists(path),
      readDatabaseVersion: (path) async {
        final database = await databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
        );
        try {
          return await database.getVersion();
        } finally {
          await database.close();
        }
      },
      deleteDatabase: (path) => databaseFactory.deleteDatabase(path),
      backupService: backupService,
      schema: schema,
    );
