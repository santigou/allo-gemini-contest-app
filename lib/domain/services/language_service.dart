import 'package:gemini_proyect/data/dao/language_dao.dart';
import 'package:gemini_proyect/domain/entities/language.dart';


class LanguageService {
  final LanguageDao _languageDao = LanguageDao();

  Future<List<Language>> fetchLanguages() async {
    try {
      return await _languageDao.getAllLanguages();
    } catch (e) {
      throw Exception('Error al obtener los idiomas: $e');
    }
  }
}
