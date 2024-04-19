import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../constants/table_attributes.dart';
import '../database/database_manager.dart';

class AthleteStore {
  final _databaseManager = DatabaseManager.instance;

  Future<int> insert(Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.insert(
        athleteTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return result;
    } catch (err) {
      final message = 'AthleteStore.insert: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>?> query(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        athleteTable,
        where: '$athleteId = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (err) {
      final message = 'AthleteStore.queryById: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>?>> queryAll() async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        athleteTable,
        orderBy: athleteName,
      );
      return result;
    } catch (err) {
      final message = 'AthleteStore.queryAll: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> delete(int id) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.delete(
        athleteTable,
        where: '$athleteId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'AthleteStore.delete: $err';
      log(message);
      throw Exception(message);
    }
  }

  Future<int> update(int id, Map<String, dynamic> map) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.update(
        athleteTable,
        map,
        where: '$athleteId = ?',
        whereArgs: [id],
      );

      return result;
    } catch (err) {
      final message = 'AthleteStore.update: $err';
      log(message);
      throw Exception(message);
    }
  }
}
