import 'package:trainers_stopwatch/models/settings_model.dart';

import '../repositories/settings_repository/settings_repository.dart';

class SettingsManager {
  SettingsManager._();
  static final repository = SettingsRepository();

  static Future<SettingsModel> query() async {
    // Load app settings
    SettingsModel? settings;
    try {
      settings = await repository.query();
    } catch (err) {
      settings = null;
    }

    // If there are no settings in the database, create one
    if (settings == null) {
      settings = SettingsModel();
      await repository.insert(settings);
    }

    return settings;
  }

  static Future<int> update(SettingsModel settings) async {
    final result = await repository.update(settings);
    return result;
  }
}
