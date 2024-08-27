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

import 'package:sqflite/sqflite.dart';

import '../database/database_manager.dart';
import '../constants/table_attributes.dart';

class TrainingStore {
  final _databaseManager = DatabaseManager.instance;

  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.insert(
        trainingTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'TrainingStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>?> query(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        trainingTable,
        where: '$trainingId = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'TrainingStore.queryById: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>?>> queryAllFromUser(int userId) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        trainingTable,
        where: '$trainingUserId = ?',
        whereArgs: [userId],
        orderBy: trainingDate,
      );
      return result;
    } catch (err) {
      final message = 'TrainingStore.queryAll: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> delete(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.delete(
        trainingTable,
        where: '$trainingId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'TrainingStore.delete: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> update(int id, Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.update(
        trainingTable,
        map,
        where: '$trainingId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'TrainingStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }
}
