import 'dart:async';
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
import 'package:gemini_proyect/ui/pages/chat/widgets/chat_app_bar.dart';
import 'package:gemini_proyect/ui/pages/chat/widgets/concepts_list_widget.dart';
import 'package:gemini_proyect/ui/pages/chat/widgets/chat_message_widget.dart';
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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  //Audio recorder
  final AudioRecorder _audioRecorder = AudioRecorder();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";
  double _confidence = 1.0;

  //Time
  Timer? _timer;
  int _seconds = 0;

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() async {
        ChatMessage chatMessage = ChatMessage(
            message: _controller.text,
            role: "user",
            subtopicId: widget.classTopic.id!);
        ResponseModel messageResponse = await widget.chatMessageService
            .createChatMessage(chatMessage);

        _messages.add(Message(
            text: _controller.text, isUser: true, id: messageResponse.result));
        _callApi();
        _controller.clear();
        _scrollToBottom();
        _controller.clear();
      });
    }
  }

  void _sendAudioMessage() {
    if (_text.isNotEmpty) {
      setState(() async {
        ChatMessage chatMessage = ChatMessage(
            message: _text,
            role: "user",
            subtopicId: widget.classTopic.id!);
        ResponseModel messageResponse = await widget.chatMessageService
            .createChatMessage(chatMessage);

        _messages.add(
            Message(text: _text, isUser: true, id: messageResponse.result));
        _callApi();
        _text = "";
        _scrollToBottom();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _seconds = 0;
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
          title: widget.classTopic.name, onConceptsPressed: _showConceptsPopup),
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
                        child: ChatMessageWidget(message: message,
                          onConceptPressed: _showConceptsPopup,),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(_seconds),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(width: 15.0, height: 30),
                    const Align(
                      alignment: Alignment.topRight,
                      child: Text(
                          "Tap again to stop recording",
                          style: TextStyle(color: Colors.red),
                      ),
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
        glowColor: Theme
            .of(context)
            .primaryColor,
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

  Future<void> _initializeChat() async {
    List<ChatMessage> existingMessages = await widget.chatMessageService
        .getChatMessagesBySubtopicId(widget.classTopic.id!);
    if (existingMessages.isNotEmpty) {
      setState(() {
        _messages.addAll(existingMessages.map((chatMessage) =>
            Message(text: chatMessage.message,
                isUser: chatMessage.role == "user",
                id: chatMessage.id!)).toList());
        _scrollToBottom();
      });
    } else {
      _callApi();
    }
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
    final apiPrompt = apiService.getChatPrompt(
        language, classTopicObjective, _messages, level ?? 1);
    final response = await apiService.geminiApiCall(apiPrompt);
    print(response);
    final Map<String, dynamic> decodedData = json.decode(response);

    final apiMessage = decodedData['message'];
    final success = decodedData['success'];
    ChatMessage chatMessage = ChatMessage(
        message: apiMessage, role: "system", subtopicId: widget.classTopic.id!);
    ResponseModel messageResponse = await widget.chatMessageService
        .createChatMessage(chatMessage);

    if (messageResponse.isError) {
      print(messageResponse.message);
      return;
    }

    List<Concept> conceptToSave = (decodedData['concepts'] as List)
        .map((concept) =>
        Concept(
            name: concept['name'] as String,
            explanation: concept['explanation'] as String,
            examples: concept['examples'] as String,
            messageId: messageResponse.result))
        .toList();

    ResponseModel conceptsResponse = await widget.conceptService
        .createManyConcepts(conceptToSave);

    if (conceptsResponse.isError) {
      print(messageResponse.message);
      return;
    }

    setState(() {
      _messages.add(
          Message(text: apiMessage, isUser: false, id: messageResponse.result));
      _scrollToBottom();
    });
    await speak(apiMessage);
    if (success as bool) {
      //TODO: desbloquear siguiente nivel y culminar el actual
      print('El usuario finalizo con exito el nivel');
      widget.subtopicService.unlockTopicByOrder(
          widget.classTopic.order + 1, widget.classTopic.topicId);
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
    if (status.isGranted) {
      if (!_isListening) {
        _startTimer();
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          print("Speech initialization successful");
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) =>
                setState(() {
                  _text = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }
                }),
          );
        } else {
          print("Speech initialization failed");
        }
      } else {
        _stopTimer();
        setState(() => _isListening = false);
        _speech.stop();
        print("Stopped listening");
        print('Recognized Words: $_text');
        _sendAudioMessage();
      }
    } else {
      print("Permission denied");
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