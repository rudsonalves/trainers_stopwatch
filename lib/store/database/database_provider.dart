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

import 'dart:developer';

import '../../common/singletons/app_settings.dart';
import '../../core/result/result.dart';
import '../constants/migration_sql_scripts.dart';
import 'database_backup.dart';
import 'database_manager.dart';
import 'database_migration.dart';

class DatabaseProvider {
  final DatabaseManager _databaseManager;
  final AppSettings _appSettings;

  const DatabaseProvider({
    required DatabaseManager databaseManager,
    required AppSettings appSettings,
  })  : _databaseManager = databaseManager,
        _appSettings = appSettings;

  AsyncResult<Unit> init() async {
    try {
      final database = await _databaseManager.database;

      try {
        await _appSettings.init();
      } on AppError {
        rethrow;
      } catch (error, stackTrace) {
        return Failure(
          AppError(
            code: AppErrorCode.storageReadFailed,
            message: 'Unable to load application settings.',
            details: (error: error, stackTrace: stackTrace),
          ),
        );
      }

      if (MigrationSqlScripts.schemeVersion <= _appSettings.dbSchemeVersion) {
        return const Success(unit);
      }

      final backupDatabase = await DatabaseBackup.backupDatabase();
      if (backupDatabase == null) {
        return const Failure(
          AppError(
            code: AppErrorCode.backupFailed,
            message: 'Unable to back up the database before migration.',
          ),
        );
      }

      try {
        await DatabaseMigration.applyMigrations(
          db: database,
          settings: _appSettings,
        );
      } catch (error, stackTrace) {
        final restored = await DatabaseBackup.restoreDatabase(backupDatabase);
        if (!restored) {
          return Failure(
            AppError(
              code: AppErrorCode.restoreFailed,
              message: 'Database migration and restoration failed.',
              details: (error: error, stackTrace: stackTrace),
            ),
          );
        }

        return Failure(
          AppError(
            code: AppErrorCode.migrationFailed,
            message: 'Database migration failed and the backup was restored.',
            details: (error: error, stackTrace: stackTrace),
          ),
        );
      }

      return const Success(unit);
    } on AppError catch (error) {
      return Failure(error);
    } catch (error, stackTrace) {
      final message = 'DatabaseProvider.init: $error';
      log(message, stackTrace: stackTrace);
      return Failure(
        AppError(
          code: AppErrorCode.unexpected,
          message: 'Unable to initialize the application.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
