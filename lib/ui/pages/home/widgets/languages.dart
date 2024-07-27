import 'package:flutter/material.dart';

import '../../../../domain/entities/language.dart';
import '../../../../domain/services/language_service.dart';

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLanguage = '';
  List<Language> languages = [];
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    try {
      final fetchedLanguages = await _languageService.fetchLanguages();
      setState(() {
        languages = fetchedLanguages;
        print(languages);
        if (languages.isNotEmpty) {
          selectedLanguage = languages.first.name;
        }
      });
    } catch (e) {
      // Maneja los errores de la manera adecuada
      print('Error al obtener los idiomas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: languages.map((language) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedLanguage = language.name;
              });
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedLanguage == language.name ? Colors.blue : Colors.transparent,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    language.image,
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(height: 4.0),
                  Text(language.name),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
