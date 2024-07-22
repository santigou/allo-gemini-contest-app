import 'dart:async';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  DatabaseService._constructor();

  Future<Database> get database async
  {
    if(_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath,"database.db");
    final database = await openDatabase(
        databasePath,
        onCreate: (db, version) async {
          await _createTables(db);
        }
    );
    return database;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE languages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
        image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        languageId INTEGER,
        name TEXT,
        description TEXT,
        objectives TEXT,
        summary TEXT,
        subtopicCount INTEGER,
        FOREIGN KEY (languageId) REFERENCES languages (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE subtopics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topicId INTEGER,
        name TEXT,
        description TEXT,
        objectives TEXT,
        summary TEXT,
        conceptCount INTEGER,
        completed INTEGER,
        order INTEGER,
        FOREIGN KEY (topicId) REFERENCES topics (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE concepts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subtopicId INTEGER,
        name TEXT,
        explanation TEXT,
        examples TEXT,
        FOREIGN KEY (subtopicId) REFERENCES subtopics (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subtopicId INTEGER,
        questionDescription TEXT,
        possibleAnswers TEXT,
        FOREIGN KEY (subtopicId) REFERENCES subtopics (id)
      )
    ''');

    await db.execute('''
    INSERT INTO languages (name,image)
    VALUES ('English','English.png'),
    ('Spanish','English.png'),
    ('French','English.png')
    ''');
  }
}
