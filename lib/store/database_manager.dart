import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'constants/table_attributes.dart';
import 'database_create_tables.dart';

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

  Future<void> init() async {
    if (_database != null) return;
    await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, dbName);

    final database = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfiguration,
    );

    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    DatabaseCreateTable.athleteTable(batch);
    DatabaseCreateTable.trainingTable(batch);
    DatabaseCreateTable.historyTable(batch);

    await batch.commit();
  }

  Future<void> _onConfiguration(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
