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

import '../constants/table_attributes.dart';
import '../database/database_manager.dart';

class HistoryStore {
  final _databaseManager = DatabaseManager.instance;

  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.insert(
        historyTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'HistoryStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>?> query(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        historyTable,
        where: '$historyId = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'HistoryStore.queryById: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>?>> queryAllFromTraining(
      int trainingId) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        historyTable,
        where: '$historyTrainingId = ?',
        whereArgs: [trainingId],
        orderBy: historyId,
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
        historyTable,
        where: '$historyId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'HistoryStore.delete: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> update(Map<String, dynamic> map) async {
    try {
      int id = map['id'];
      final database = await _databaseManager.database;

      final result = await database.update(
        historyTable,
        map,
        where: '$historyId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'HistoryStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }
}
