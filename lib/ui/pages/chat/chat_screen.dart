import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/entities/chat_message.dart';
import 'package:gemini_proyect/domain/entities/concept.dart';
import 'package:gemini_proyect/domain/entities/response_model.dart';
import 'package:gemini_proyect/domain/entities/subtopic.dart';
import 'package:gemini_proyect/domain/services/api_service.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
import 'package:gemini_proyect/domain/services/subtopic_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../domain/services/audio_recorder_service.dart';
import '../../../domain/services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final Subtopic classTopic;
  final IChatMessageService chatMessageService;
  final ConceptService conceptService;
  final SubtopicService subtopicService;
  const ChatScreen({super.key, required this.classTopic, required this.chatMessageService, required this.conceptService, required this.subtopicService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  String _text = "Press the microphone to start speaking";
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  //Audio recorder
  final AudioRecorder _audioRecorder = AudioRecorder();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String text = "";
  double _confidence = 1.0;

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _controller.text, isUser: true));
        _controller.clear();
      });
      ChatMessage chatMessage = ChatMessage(
          message: _controller.text,
          role: "user",
          subtopicId: widget.classTopic.id!);
      widget.chatMessageService.createChatMessage(chatMessage);
      _callApi();
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _sendAudioMessage() {
    if (_text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _text, isUser: true));
        _text = "";
      });
      ChatMessage chatMessage = ChatMessage(
          message: _text,
          role: "user",
          subtopicId: widget.classTopic.id!);
      widget.chatMessageService.createChatMessage(chatMessage);
      _callApi();
      _text = "";
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _callApi();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
                  controller: _scrollController,
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
                      focusNode: _focusNode,
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
                  if (!_isListening) IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.deepPurple,
                    onPressed: _sendMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    iconSize: 30,
                    color: Colors.deepPurple,
                    onPressed: _toggleListening,
                  ),
                ],
              ),
            ),
          ),
          if (_isListening)
            Positioned(
              bottom: 17,
              left: 20,
              child: Container(
                margin: const EdgeInsets.only(right: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '0:00',
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(width: 15.0, height: 30),
                    Text(
                      'Tap again to stop recording',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        startDelay: const Duration(milliseconds: 100),
        child: FloatingActionButton(
          onPressed: _toggleListening,
          child: Icon(_isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }

  Future<void> _callApi() async {
    //TODO: Cambiar a inyection?
    ApiService apiService = ApiService();

    //TODO: Enviar el lenguaje correctamente
    final SharedPreferences prefs = await _prefs;
    String language = prefs.getString("languageName") ?? "English";
    int? level = prefs.getInt("topicLevel");

    //TODO: Add the level thinking on sharedPreferences
    final classTopicObjective = widget.classTopic.objectives;
    //TODO: Get the level of the topic
    final apiPrompt = apiService.getChatPrompt(language, classTopicObjective, _messages, level ?? 1);
    final response = await apiService.geminiApiCall(apiPrompt);
    print(response);
    final Map<String, dynamic> decodedData = json.decode(response);

    final apiMessage = decodedData['message'];
    final success = decodedData['success'];
    ChatMessage chatMessage = ChatMessage(message: apiMessage, role: "system", subtopicId: widget.classTopic.id!);
    ResponseModel messageResponse = await widget.chatMessageService.createChatMessage(chatMessage);

    if (messageResponse.isError) {
      print(messageResponse.message);
      return;
    }

    List<Concept> conceptToSave = (decodedData['concepts'] as List)
        .map((concept) => Concept(
        name: concept['name'] as String,
        explanation: concept['explanation'] as String,
        examples: concept['examples'] as String,
        messageId: messageResponse.result))
        .toList();

    ResponseModel conceptsResponse = await widget.conceptService.createManyConcepts(conceptToSave);

    if (conceptsResponse.isError) {
      print(messageResponse.message);
      return;
    }

    setState(() {
      _messages.add(Message(text: apiMessage, isUser: false));
      _scrollToBottom(); // Scroll to bottom after receiving message
    });
    await speak(apiMessage);
    if (success as bool) {
      //TODO: desbloquear siguiente nivel y culminar el actual
      print('El usuario finalizo con exito el nivel');
      widget.subtopicService.unlockTopicByOrder(widget.classTopic.order + 1, widget.classTopic.topicId);
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage('en-US');
    //await _flutterTts.setVoice({"name": "en-in-x-cxx#male_1-local", "locale": "en-US"});
    await _flutterTts.speak(text);
  }

  void _toggleListening() async {
    PermissionStatus status = await Permission.microphone.request();
    if(status.isGranted){
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if(available){
          print("Speech initialization successful");
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
              if(val.hasConfidenceRating && val.confidence > 0){
                _confidence = val.confidence;
              }
            }),
          );
        }else{
          print("Speech initialization failed");
        }
      } else {
        setState(() => _isListening = false);
        _speech.stop();
        print("Stopped listening");
        print('Recognized Words: $_text');
        _sendAudioMessage();
      }
    }else{
      print("Permission denied");
    }
  }

}