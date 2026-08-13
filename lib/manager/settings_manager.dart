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

import '../common/models/settings_model.dart';
import '../core/result/errors/app_error.dart';
import '../repositories/settings_repository/settings_repository.dart';

class SettingsManager {
  SettingsManager._();
  static final repository = SettingsRepository();

  static Future<SettingsModel> query() async {
    final settings = await repository.query();

    // If there are no settings in the database, create one
    if (settings == null) {
      final newSettings = SettingsModel();
      try {
        await repository.insert(newSettings);
      } catch (error, stackTrace) {
        throw AppError(
          code: AppErrorCode.storageWriteFailed,
          message: 'Unable to create the initial application settings.',
          details: (error: error, stackTrace: stackTrace),
        );
      }
      return newSettings;
    }

    return settings;
  }

  static Future<int> update(SettingsModel settings) async {
    final result = await repository.update(settings);
    return result;
  }
}
