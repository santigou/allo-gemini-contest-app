import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService dbInstace = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    return (_db !=null) ? _db! : await getDatabase();
  }

  Future<Database> getDatabase() async{
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath,"gemini.db");
    final database = await openDatabase(
        databasePath,
      onCreate: (db, version) => {
          db.execute('''
          CREATE TABLE ...
          ''')
        //TODO: CREATE A FUNTION TO CREATE THE DATABASE
      }
    );
    return database;
  }
}