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
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/table_attributes.dart';
import 'database_create_tables.dart';

class DatabaseCreationException implements Exception {
  final String message;

  DatabaseCreationException(this.message);

  @override
  String toString() => 'DatabaseCreationException: $message';
}

class DatabaseManager {
  DatabaseManager._();
  static final DatabaseManager _instance = DatabaseManager._();
  static DatabaseManager get instance => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    if (_database == null) return;

    await _database!.close();
    _database = null;
  }

  Future<Database> _initDatabase() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, dbName);
    // await deleteDatabase(path);
    log('Database path: $path');

    try {
      final database = await openDatabase(
        path,
        version: dbVersion,
        onCreate: _onCreate,
        onConfigure: _onConfiguration,
      );
      log('Database opened successfully');
      return database;
    } catch (err) {
      log('Create table error: $err');
      if (err is DatabaseCreationException) {
        await deleteDatabase(path);
      }
      exit(1);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      log('Create database tables...');
      Batch batch = db.batch();

      DatabaseCreateTable.settingsTable(batch);
      DatabaseCreateTable.userTable(batch);
      DatabaseCreateTable.trainingTable(batch);
      DatabaseCreateTable.historyTable(batch);

      await batch.commit();
      log('Create database tables finish...');
    } catch (err) {
      log('DatabaseManager._onCreate: $err');
      throw DatabaseCreationException(err.toString());
    }
  }

  Future<void> _onConfiguration(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
