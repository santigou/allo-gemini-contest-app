import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/entities/chat_message.dart';
import 'package:gemini_proyect/domain/entities/subtopic.dart';
import 'package:gemini_proyect/domain/services/api_service.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../domain/services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final Subtopic classTopic;
  final IChatMessageService chatMessageService;
  const ChatScreen({super.key, required this.classTopic, required this.chatMessageService,});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _controller.text, isUser: true));
        _controller.clear();
      });
      ChatMessage chatMessage = ChatMessage(message: _controller.text,
          role: "user",
          subtopicId: widget.classTopic.id!);
      widget.chatMessageService.createChatMessage(chatMessage);
      _callApi();
      _controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _callApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classTopic.name),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Optional: Subtle background color or image
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, // or use a subtle background image
            ),
          ),

          // Chat messages and input field
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.isUser
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Colors.blueAccent
                              : Colors.deepPurple,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          message.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Message buttons and Microphone
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.deepPurple,
                    onPressed: _sendMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    iconSize: 30,
                    color: Colors.deepPurple,
                    onPressed: () {
                      // Implementació
                      // n del botón de micrófono
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callApi() async {
    //TODO: Cambiar a inyection?
    ApiService apiService = new ApiService();

    //TODO: Enviar el lenguaje correctamente
    final SharedPreferences prefs = await _prefs;
    String language = prefs.getString("languageName") ?? "English";
    int? level = prefs.getInt("topicLevel");

    //TODO: Add the level thinking on sharedPreferences
    final classTopicObjective = widget.classTopic.objectives;
    //TODO: Get the level of the topic
    final apiPrompt = apiService.getChatPrompt(language, classTopicObjective, _messages, level??1);
    final response = await apiService.geminiApiCall(apiPrompt);
    print(response);
    final Map<String, dynamic> decodedData = json.decode(response);
    final apiMessage = decodedData['message'];
    final success = decodedData['success'];
    setState(() {
      _messages.add(Message(text: apiMessage, isUser: false));
    });
    await speak(apiMessage);
    if (success == 'true') {
      //TODO: desbloquear siguiente nivel y culminar el actual
      print('El usuario finalizo con exito el nivel');
    }
  }

  Future<void> speak(String text) async{
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVoice({"name": "en-in-x-cxx#male_1-local", "locale": "en-US"});
    await _flutterTts.speak(text);
  }
}
