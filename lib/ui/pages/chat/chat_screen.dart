import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/entities/chat_message.dart';
import 'package:gemini_proyect/domain/entities/concept.dart';
import 'package:gemini_proyect/domain/entities/response_model.dart';
import 'package:gemini_proyect/domain/entities/subtopic.dart';
import 'package:gemini_proyect/domain/services/api_service.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
import 'package:gemini_proyect/domain/services/subtopic_service.dart';
import 'package:gemini_proyect/ui/pages/chat/widgets/chat_app_bar.dart';
import 'package:gemini_proyect/ui/pages/chat/widgets/concepts_list_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the microphone to start speaking";
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _controller.text, isUser: true));
        ChatMessage chatMessage = ChatMessage(
            message: _controller.text,
            role: "user",
            subtopicId: widget.classTopic.id!);
        widget.chatMessageService.createChatMessage(chatMessage);
        _callApi();
        _controller.clear();
        _scrollToBottom();
        _controller.clear();
      });
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
    _initializeChat();
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
      appBar: ChatAppBar(title: widget.classTopic.name, onMoreOptionsPressed: _showConceptsPopup),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
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
                  IconButton(
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
        ],
      ),
    );
  }

  Future<void> _initializeChat() async {
    List<ChatMessage> existingMessages = await widget.chatMessageService.getChatMessagesBySubtopicId(widget.classTopic.id!);
    if (existingMessages.isNotEmpty) {
      setState(() {
        _messages.addAll(existingMessages.map((chatMessage) => Message(text: chatMessage.message, isUser: chatMessage.role == "user")).toList());
        _scrollToBottom();
      });
    } else {
      _callApi();
    }
  }

  Future<void> _callApi() async {
    ApiService apiService = ApiService();

    final SharedPreferences prefs = await _prefs;
    String language = prefs.getString("languageName") ?? "English";
    int? level = prefs.getInt("topicLevel");

    final classTopicObjective = widget.classTopic.objectives;
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
      _scrollToBottom();
    });
    await speak(apiMessage);
    if (success as bool) {
      print('El usuario finalizo con exito el nivel');
      widget.subtopicService.unlockTopicByOrder(widget.classTopic.order + 1, widget.classTopic.topicId);
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.speak(text);
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            print(result);
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  Future<void> _showConceptsPopup({int? messageId}) async {
    try {

      List<Concept> concepts;

      if (messageId == null){
        concepts = await widget.conceptService.getConceptsBySubtopicId(widget.classTopic.id!);
      }else{
         //TODO: manage when selected message
        concepts = await widget.conceptService.getConceptsByMessageId(messageId);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 400,
              width: 300,
              child: ConceptsPopup(concepts: concepts),
            ),
          );
        },
      );
    } catch (error) {
      print("Error fetching concepts: $error");
    }
  }

}
