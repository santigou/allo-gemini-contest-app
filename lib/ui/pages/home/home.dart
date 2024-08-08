import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
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
  final IChatMessageService chatMessageService;
  final ConceptService conceptService;

  const Home({
    super.key,
    required this.apiService,
    required this.topicService,
    required this.databaseService,
    required this.subtopicService,
    required this.chatMessageService,
    required this.conceptService,
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
  ValueNotifier<List<Topic>> topicsNotifier = ValueNotifier<List<Topic>>([]);
  String? language;

  void setRandomText() {
    final random = Random();
    final randomText = randomTextList[random.nextInt(randomTextList.length)];
    setState(() {
      _controller.text = randomText;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final SharedPreferences prefs = await _prefs;
    int languageId = prefs.getInt("languageId") ?? 1;
    List<Topic> topics = await widget.topicService.getAllTopics(languageId: languageId);
    topicsNotifier.value = topics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, bottom: 16, left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'What do you want to learn...',
                ),
                onEditingComplete: () {
                  if (_controller.text.isEmpty) {
                    setRandomText();
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: LanguageSelector(
                      languageNotifier: languageNotifier,
                      topicsNotifier: topicsNotifier,
                      topicService: widget.topicService,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<int>(
                      items: const [
                        DropdownMenuItem<int>(value: 1, child: Text("⭐")),
                        DropdownMenuItem<int>(value: 2, child: Text("⭐⭐")),
                        DropdownMenuItem<int>(value: 3, child: Text("⭐⭐⭐")),
                      ],
                      onChanged: _onSelectLevel,
                      value: _level,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _callApi,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TopicsList(
                  topicsNotifier: topicsNotifier,
                  topicService: widget.topicService,
                  subtopicService: widget.subtopicService,
                  chatMessageService: widget.chatMessageService,
                  conceptService: widget.conceptService,
                  languageNotifier: languageNotifier,
                ),
              ),
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

  void _onSelectLevel (int? selectedLevel){
    if(selectedLevel is int){
      setState(() {
        _level = selectedLevel;
      });
    }
  }

  Future<void> _callApi() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("topicLevel", _level);
    final userPrompt = _controller.text.isEmpty ? null : _controller.text;
    List<Topic> existingTopics = await widget.topicService.getAllTopics(languageId: prefs.getInt("languageId") ?? 1);
    List<String> topicNames = existingTopics.map((topic) => topic.name).toList();
    String topicString = "";

    if(topicNames.isNotEmpty){
      topicString = topicNames.reduce((topics, topic) => "$topics,$topic");
    }

    final apiPrompt = widget.apiService.getTopicPrompt(prefs.getString("languageName") ?? "English", userPrompt: userPrompt, existingTopics: topicString, level: levels[_level]);
    final response = await widget.apiService.geminiApiCall(apiPrompt);

    final Map<String, dynamic> decodedData = json.decode(response);

    startTopicViewModel topicViewModel = startTopicViewModel.fromMap(decodedData);
    int languageId = await _getLanguageSelectedId();

    ResponseModel responseModel = await widget.topicService.createTopic(topicViewModel,languageId,_level);

    if (responseModel.isError) {
      print("Error: ${responseModel.message}");
      return;
    }

    int topicId = responseModel.result;
    List<SubtopicViewmodel> steps = (decodedData['subtopics'] as List).map((subtopic) => SubtopicViewmodel.fromMap(subtopic)).toList();
    responseModel = await widget.subtopicService.createManySubtopics(steps, topicId);

    if (responseModel.isError) {
      print("Error: ${responseModel.message}");
      return;
    }

    // Actualizar la lista de temas
    _loadTopics();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StepsScreen(
          steps: responseModel.result,
          classTopicName: decodedData['name'],
          chatMessageService: widget.chatMessageService,
          conceptService: widget.conceptService,
          subtopicService: widget.subtopicService,
        ),
      ),
    );
  }
}
