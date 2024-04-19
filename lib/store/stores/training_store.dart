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

  Future<List<Map<String, dynamic>?>> queryAllFromAthlete(int athleteId) async {
    try {
      final database = await _databaseManager.database;

      final result = await database.query(
        trainingTable,
        where: '$trainingAthleteId = ?',
        whereArgs: [athleteId],
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
