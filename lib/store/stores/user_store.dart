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
import '../constants/table_sql_scripts.dart';
import '../database/database_manager.dart';

class UserStore {
  final _databaseManager = DatabaseManager.instance;

  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.insert(
        userTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'UserStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>?> query(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        userTable,
        where: '$userId = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'UserStore.queryById: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>?>> queryAll() async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        userTable,
        orderBy: userName,
      );
      return result;
    } catch (err) {
      final message = 'UserStore.queryAll: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> delete(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.delete(
        userTable,
        where: '$userId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'UserStore.delete: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> update(int id, Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.update(
        userTable,
        map,
        where: '$userId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'UserStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<List<String>> getImagesList() async {
    try {
      final database = await _databaseManager.database;

      final result = await database.rawQuery(getUserImagesListSQL);
      return result.map((item) => item[userPhoto] as String).toList();
    } catch (err) {
      final message = 'UserStore.getImagesList: $err';
      log(message);
      throw Exception(message);
    }
  }
}
