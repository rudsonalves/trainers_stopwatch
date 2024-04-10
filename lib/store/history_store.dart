import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'constants/table_attributes.dart';
import 'database_manager.dart';

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

  Future<int> update(int id, Map<String, dynamic> map) async {
    try {
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
