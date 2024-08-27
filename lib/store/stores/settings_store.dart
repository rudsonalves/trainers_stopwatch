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
