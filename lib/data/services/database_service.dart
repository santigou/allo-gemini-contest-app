import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InitDatabaseRepository {
  Future<Database> createDatabase() async {
    final dbPath = await getDatabasesPath();
    final database = openDatabase(
      join(dbPath, 'my_language_app.db'),
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
    return database;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE languages (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE topics (
        id TEXT PRIMARY KEY,
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
        id TEXT PRIMARY KEY,
        topicId INTEGER,
        name TEXT,
        description TEXT,
        objectives TEXT,
        summary TEXT,
        conceptCount INTEGER,
        completed INTEGER,
        previousSubtopicId INTEGER,
        nextSubtopicId INTEGER,
        FOREIGN KEY (topicId) REFERENCES topics (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE concepts (
        id TEXT PRIMARY KEY,
        subtopicId INTEGER,
        name TEXT,
        explanation TEXT,
        examples TEXT,
        FOREIGN KEY (subtopicId) REFERENCES subtopics (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        subtopicId INTEGER,
        questionDescription TEXT,
        possibleAnswers TEXT,
        FOREIGN KEY (subtopicId) REFERENCES subtopics (id)
      )
    ''');
  }
}
