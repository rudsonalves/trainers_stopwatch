import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/data/services/database/database_backup_service.dart';

void main() {
  test('creates an identifiable copy without changing the source', () async {
    final directory = await Directory.systemTemp.createTemp('stopwatch-bkp-');
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/stopwatch.db');
    await source.writeAsString('database-content');
    final service = DatabaseBackupService(
      clock: () => DateTime.utc(2026, 8, 13, 15, 30),
    );

    final result = await service.preserve(source.path);

    expect(result.isSuccess, isTrue);
    expect(result.value, contains('stopwatch.db.backup-2026-08-13T15-30-00'));
    expect(await File(result.value!).readAsString(), 'database-content');
    expect(await source.readAsString(), 'database-content');
  });

  test('returns backupFailed when the source does not exist', () async {
    final service = DatabaseBackupService(clock: DateTime.now);

    final result = await service.preserve('/missing/stopwatch.db');

    expect(result.isFailure, isTrue);
    expect(result.error!.code, AppErrorCode.backupFailed);
  });
}
