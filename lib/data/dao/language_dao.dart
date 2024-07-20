import '../../domain/entities/language.dart';
import '../services/database_service.dart';

class LanguageDao {
  Future<List<Language>> getAllLanguages() async {
    final db = await DatabaseService.instance.database;
    final languages = await db.rawQuery("SELECT * FROM languages");
    return languages.map((l) => Language.fromSqfliteDatabase(l)).toList();
  }
}