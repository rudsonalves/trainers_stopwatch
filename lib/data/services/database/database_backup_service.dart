import 'dart:io';

import 'package:path/path.dart' as path;

import '/core/result/result.dart';

typedef BackupClock = DateTime Function();

final class DatabaseBackupService {
  final BackupClock _clock;

  const DatabaseBackupService({required BackupClock clock}) : _clock = clock;

  AsyncResult<String> preserve(String databasePath) async {
    try {
      final source = File(databasePath);
      if (!await source.exists()) {
        return Failure(
          AppError(
            code: AppErrorCode.backupFailed,
            message: 'The database file does not exist for backup.',
            details: databasePath,
          ),
        );
      }

      final timestamp = _clock().toUtc().toIso8601String().replaceAll(':', '-');
      final backupPath = path.join(
        path.dirname(databasePath),
        '${path.basename(databasePath)}.backup-$timestamp',
      );
      await source.copy(backupPath);
      return Success(backupPath);
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.backupFailed,
          message: 'Unable to back up the application database.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
