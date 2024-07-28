import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/entities/language.dart';
import '../../../../domain/services/language_service.dart';

class LanguageSelector extends StatefulWidget {
  final ValueNotifier<int> languageNotifier;

  const LanguageSelector({
    Key? key,
    required this.languageNotifier,
  }) : super(key: key);

  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLanguage = '';
  List<Language> languages = [];
  final LanguageService _languageService = LanguageService();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    final SharedPreferences prefs = await _prefs;
    try {
      final fetchedLanguages = await _languageService.fetchLanguages();
      setState(() {
        languages = fetchedLanguages;
        print(languages);
        if (languages.isNotEmpty) {
          selectedLanguage = prefs.getString("languageName")??"None";
        }
      });
    } catch (e) {
      // Maneja los errores de la manera adecuada
      print('Error al obtener los idiomas: $e');
    }
  }

  Future<void> _onLanguageSelect(Language language) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("languageId", language.id); // TODO: CHANGE THIS FOR CONSTANTS
    prefs.setString("languageName", language.name);
    setState(() {
      selectedLanguage = prefs.getString("languageName")!;
      widget.languageNotifier.value = language.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: languages.map((language) {
          return GestureDetector(
            onTap: () => _onLanguageSelect(language),
            child: Container(
              width: 100.0,
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
