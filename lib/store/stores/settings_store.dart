import 'dart:developer';

import '../constants/table_attributes.dart';
import '../database/database_manager.dart';

class SettingsStore {
  final _databaseManager = DatabaseManager.instance;

  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.insert(
        settingsTable,
        map,
      );

      return result;
    } catch (err) {
      final message = 'SettingsStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>?> query() async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        settingsTable,
        where: '$settingsId = ?',
        whereArgs: [1],
      );

      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'SettingsStore.query: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> update(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.update(
        settingsTable,
        map,
        where: '$settingsId = ?',
        whereArgs: [1],
      );

      return result;
    } catch (err) {
      final message = 'SettingsStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }
}
