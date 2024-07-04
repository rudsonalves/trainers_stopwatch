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
