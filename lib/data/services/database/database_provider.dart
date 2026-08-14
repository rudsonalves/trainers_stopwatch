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

import '/common/singletons/app_settings.dart';
import '/core/result/result.dart';
import '/data/repositories/settings/settings_repository.dart';
import '/data/services/database/database_service.dart';
import '/ui/app/app_appearance_state.dart';

class DatabaseProvider {
  final DatabaseService _databaseService;
  final AppSettings _appSettings;
  final SettingsRepository _settingsRepository;
  final AppAppearanceState _appearanceState;

  const DatabaseProvider({
    required DatabaseService databaseService,
    required AppSettings appSettings,
    required SettingsRepository settingsRepository,
    required AppAppearanceState appearanceState,
  })  : _databaseService = databaseService,
        _appSettings = appSettings,
        _settingsRepository = settingsRepository,
        _appearanceState = appearanceState;

  AsyncResult<Unit> init() async {
    try {
      final databaseResult = await _databaseService.open();
      if (databaseResult.isFailure) return Failure(databaseResult.error!);

      try {
        await _appSettings.init(_settingsRepository, _appearanceState);
        _appearanceState.synchronize(_settingsRepository.current!);
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
