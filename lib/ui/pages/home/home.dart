import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gemini_proyect/data/services/database_service.dart';
import 'package:gemini_proyect/domain/services/api_service.dart';
import 'package:gemini_proyect/domain/services/topic_service.dart';
import 'package:gemini_proyect/domain/viewmodels/start_topic_viewmodel.dart';
import 'package:gemini_proyect/ui/pages/home/widgets/languages.dart';
import 'package:gemini_proyect/ui/pages/home/widgets/topics_list.dart';
import 'package:gemini_proyect/ui/pages/playground/steps_screen.dart';

import '../../../domain/entities/response_model.dart';

class Home extends StatefulWidget {
  final ApiService apiService;
  final TopicService topicService;
  final DatabaseService databaseService;
  const Home({super.key, required this.apiService, required this.topicService, required this.databaseService});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();
  final List<String> randomTextList = [
    "Quiero prepararme para una entrevista como programador backend junior en ingles",
    "Voy a trabajar como mecero en Italia que necesito saber?",
    "Quiero aprender ingles para responder correctamente a mi profesor",
    "Tendre un examen oral en portuges, soy estudiante de universidad"
  ];

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
      // Menu
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

      //Cuadro de texto y botones
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LanguageSelector(), // Agrega el widget LanguageSelector aquí
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'What do you want do learn...',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: setRandomText,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Random'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _callApi,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                    ),
                  ),
                ],
              ),
              TopicsList(topicService: widget.topicService, languageId: 1,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callApi() async {
    final userPrompt = _controller.text.isEmpty ? null : _controller.text;
    final apiPrompt = widget.apiService.getTopicPrompt("English", userPrompt: userPrompt);
    final response = await widget.apiService.geminiApiCall(apiPrompt);

    final Map<String, dynamic> decodedData = json.decode(response);

    startTopicViewModel topicViewModel = startTopicViewModel.fromMap(decodedData);
    int languageId = 1; // TODO: Obtén el id del idioma seleccionado

    ResponseModel responseModel = await widget.topicService.createTopic(topicViewModel, languageId);

    if (!responseModel.isError) {
      int topicId = responseModel.result;
      List<Map<String, dynamic>> steps = (decodedData['subtopics'] as List)
          .map((subtopic) => {'name': subtopic['name'], 'summary': subtopic['summary'], 'order': subtopic['order']})
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StepsScreen(
            steps: steps,
            classTopicName: decodedData['name'],
          ),
        ),
      );
    } else {
      print("Error: ${responseModel.message}");
    }
  }
  List<String> _parseResponse(String response) {
    try {
      return List<String>.from(jsonDecode(response));
    } catch (e) {
      //TODO eliminar print
      print("Error al decodificar la respuesta: $e");
      return [];
    }
  }
}
