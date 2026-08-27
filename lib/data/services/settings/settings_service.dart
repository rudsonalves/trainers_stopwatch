import 'package:sqflite/sqflite.dart';

import '/core/result/result.dart';
import '/data/services/database/database_service.dart';
import '/domain/common/settings/models/settings.dart';
import '../database/table_attributes.dart';
import 'settings_mapper.dart';

sealed class SettingsLookup {
  const SettingsLookup();
}

final class SettingsFound extends SettingsLookup {
  final Settings settings;

  const SettingsFound(this.settings);
}

final class SettingsMissing extends SettingsLookup {
  const SettingsMissing();
}

class SettingsService {
  final DatabaseService _databaseService;
  final SettingsMapper _mapper;

  const SettingsService({
    required DatabaseService databaseService,
    required SettingsMapper mapper,
  })  : _databaseService = databaseService,
        _mapper = mapper;

  AsyncResult<SettingsLookup> read() async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final rows = await databaseResult.value!.query(
        settingsTable,
        where: '$settingsId = ?',
        whereArgs: const [1],
        limit: 1,
      );
      if (rows.isEmpty) return const Success(SettingsMissing());

      final mapped = _mapper.fromMap(rows.first);
      if (mapped.isFailure) return Failure(mapped.error!);
      return Success(SettingsFound(mapped.value!));
    } catch (error, stackTrace) {
      return Failure(_readError(error, stackTrace));
    }
  }

  AsyncResult<Settings> insert(Settings settings) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final id = await databaseResult.value!.insert(
        settingsTable,
        _mapper.toMap(settings),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return Settings.create(
        id: id,
        splitDistance: settings.splitDistance,
        lapDistance: settings.lapDistance,
        brightness: settings.brightness,
        protectedActionsHintSeen: settings.protectedActionsHintSeen,
        contrast: settings.contrast,
        language: settings.language,
        refreshInterval: settings.refreshInterval,
      );
    } catch (error, stackTrace) {
      return Failure(_writeError(error, stackTrace));
    }
  }

  AsyncResult<Unit> update(Settings settings) async {
    final databaseResult = await _databaseService.open();
    if (databaseResult.isFailure) return Failure(databaseResult.error!);

    try {
      final count = await databaseResult.value!.update(
        settingsTable,
        _mapper.toMap(settings),
        where: '$settingsId = ?',
        whereArgs: const [1],
      );
      if (count != 1) {
        return const Failure(
          AppError(
            code: AppErrorCode.storageWriteFailed,
            message: 'The application settings record was not updated.',
          ),
        );
      }
      return const Success(unit);
    } catch (error, stackTrace) {
      return Failure(_writeError(error, stackTrace));
    }
  }

  AppError _readError(Object error, StackTrace stackTrace) => AppError(
        code: AppErrorCode.storageReadFailed,
        message: 'Unable to read application settings.',
        details: (error: error, stackTrace: stackTrace),
      );

  AppError _writeError(Object error, StackTrace stackTrace) => AppError(
        code: AppErrorCode.storageWriteFailed,
        message: 'Unable to write application settings.',
        details: (error: error, stackTrace: stackTrace),
      );
}
