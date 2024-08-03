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
  String? selectedLanguage;
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
          final storedLanguage = prefs.getString("languageName");
          if (storedLanguage != null && languages.any((lang) => lang.name == storedLanguage)) {
            selectedLanguage = storedLanguage;
          } else {
            selectedLanguage = languages.first.name;
          }
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
      selectedLanguage = language.name;
      widget.languageNotifier.value = language.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Añadir padding horizontal
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedLanguage,
        hint: Text('Select Language'),
        onChanged: (String? newLanguage) {
          if (newLanguage != null) {
            final selected = languages.firstWhere((language) => language.name == newLanguage);
            _onLanguageSelect(selected);
          }
        },
        items: languages.map<DropdownMenuItem<String>>((Language language) {
          return DropdownMenuItem<String>(
            value: language.name,
            child: Text(language.name),
          );
        }).toList(),
      ),
    );
  }
}
