

import '../../data/dao/language_dao.dart';
import '../entities/language.dart';

abstract class LanguageRepositoryInterface {
  Future<List<Language>> getAllLanguages();
}

// TODO: Adjust Dependency Injection
class LanguageRepository implements LanguageRepositoryInterface{
  final LanguageDao _languageDao= LanguageDao();

  @override
  Future<List<Language>> getAllLanguages() => _languageDao.getAllLanguages();
}