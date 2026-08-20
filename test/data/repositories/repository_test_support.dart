import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';
import 'package:trainers_stopwatch/data/services/database/database_schema.dart';
import 'package:trainers_stopwatch/data/services/database/database_service.dart';

class UnusedDatabaseService extends DatabaseService {
  UnusedDatabaseService()
      : super(
          databaseDirectoryPath: () async => '',
          openDatabase: (_, options) async => throw UnimplementedError(),
          databaseExists: (_) async => false,
          readDatabaseVersion: (_) async => 1006,
          deleteDatabase: (_) async {},
          backupService: DatabaseBackupService(clock: DateTime.now),
          schema: const DatabaseSchema(),
        );

  @override
  AsyncResult<Database> open() async => throw UnimplementedError();
}
