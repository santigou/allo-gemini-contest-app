import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/utils/level.dart';
import 'package:gemini_proyect/ui/pages/home/widgets/languages.dart';
import 'package:gemini_proyect/ui/pages/home/widgets/topics_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/database_service.dart';
import '../../../domain/entities/response_model.dart';
import '../../../domain/entities/topic.dart';
import '../../../domain/services/api_service.dart';
import '../../../domain/services/subtopic_service.dart';
import '../../../domain/services/topic_service.dart';
import '../../../domain/viewmodels/start_topic_viewmodel.dart';
import '../../../domain/viewmodels/subtopic_viewmodel.dart';
import '../playground/steps_screen.dart';

class Home extends StatefulWidget {
  final ApiService apiService;
  final TopicService topicService;
  final SubtopicService subtopicService;
  final DatabaseService databaseService;

  const Home({
    super.key,
    required this.apiService,
    required this.topicService,
    required this.databaseService,
    required this.subtopicService,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final TextEditingController _controller = TextEditingController();
  int _level = 1;
  final List<String> randomTextList = [
    "Quiero prepararme para una entrevista como programador backend junior en ingles",
    "Voy a trabajar como mesero en Italia, ¿qué necesito saber?",
    "Quiero aprender inglés para responder correctamente a mi profesor",
    "Tendré un examen oral en portugués, soy estudiante de universidad",
  ];

  ValueNotifier<int> languageNotifier = ValueNotifier<int>(1);
  String? language;

  void setRandomText() {
    final random = Random();
    final randomText = randomTextList[random.nextInt(randomTextList.length)];
    setState(() {
      _controller.text = randomText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountEmail: Text("danielsantiago@gmail.com"),
              accountName: Text("Daniel Santiago"),
              currentAccountPicture: Icon(Icons.person),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("H O M E"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("S E T T I N G S"),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExpansionTile(
                onExpansionChanged: _getLanguageSelected,//TODO Check to change this
                title: Text(language??'Select Language'),
                children: [
                  LanguageSelector(
                    languageNotifier: languageNotifier,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What do you want to learn...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Añade un espacio entre el TextField y el DropdownButton
                  DropdownButton<int>(
                    items: const [
                      DropdownMenuItem<int>(value: 1, child: Text("⭐")),
                      DropdownMenuItem<int>(value: 2, child: Text("⭐⭐")),
                      DropdownMenuItem<int>(value: 3, child: Text("⭐⭐⭐")),
                    ],
                    onChanged: _onSelectLevel,
                    value: _level,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _callEmptyApi,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Random'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _callApi,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child:
              ValueListenableBuilder<int>(
                valueListenable: languageNotifier,
                builder: (context, languageId, child) {
                  return TopicsList(
                    topicService: widget.topicService,
                    subtopicService: widget.subtopicService,
                    languageId: languageId,
                  );
                },
              ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getLanguageSelectedId() async {
    final SharedPreferences prefs = await _prefs;
    try {
      return prefs.getInt("languageId") ?? 1;
    } catch (e) {
      return 1;
    }
  }

  Future<void> _getLanguageSelected(bool value) async {
    final SharedPreferences prefs = await _prefs;
    try {
      String found = prefs.getString("languageName") ?? "Select language";
      setState(() {
        language = found;
      });
    } catch (e) {
    }
  }

  void _onSelectLevel (int? selectedLevel){
    if(selectedLevel is int){
      setState(() {
        _level = selectedLevel;
      });
    }
  }

  Future<void> _callApi() async {
    final SharedPreferences prefs = await _prefs;
    final userPrompt = _controller.text.isEmpty ? null : _controller.text;
    List<Topic> existingTopics = await widget.topicService.getAllTopics(languageId: prefs.getInt("languageId") ?? 1);
    List<String> topicNames = existingTopics.map((topic) => topic.name).toList();
    String topicString = "";
    if(topicNames.length > 0){
      topicString = topicNames.reduce((topics, topic) => "$topics,$topic");
    }

    final apiPrompt = widget.apiService.getTopicPrompt(prefs.getString("languageName") ?? "English", userPrompt: userPrompt, existingTopics: topicString, level: levels[_level]);//TODO ADD LEVEL
    final response = await widget.apiService.geminiApiCall(apiPrompt);

    final Map<String, dynamic> decodedData = json.decode(response);

    startTopicViewModel topicViewModel = startTopicViewModel.fromMap(decodedData);
    int languageId = await _getLanguageSelectedId();

    ResponseModel responseModel = await widget.topicService.createTopic(topicViewModel, languageId, _level);

    if (responseModel.isError) {
      print("Error: ${responseModel.message}");
      return;
    }
    int topicId = responseModel.result;
    List<SubtopicViewmodel> steps = (decodedData['subtopics'] as List)
        .map((subtopic) => SubtopicViewmodel.fromMap(subtopic))
        .toList();

    responseModel = await widget.subtopicService.createManySubtopics(steps, topicId);

    if (responseModel.isError) {
      print("Error: ${responseModel.message}");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StepsScreen(
          steps: responseModel.result,
          classTopicName: decodedData['name'],
        ),
      ),
    );
  }

  Future<void> _callEmptyApi() async {
    _controller.text = "";
    await _callApi();
  }

  List<String> _parseResponse(String response) {
    try {
      return List<String>.from(jsonDecode(response));
    } catch (e) {
      print("Error al decodificar la respuesta: $e");
      return [];
    }
  }
}
