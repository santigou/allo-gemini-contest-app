import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> classTopic;
  const ChatScreen({super.key, required this.classTopic});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _controller.text, isUser: true));
        _controller.clear();
      });
      _callApi(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classTopic['name']),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/professor.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Chat messages and input field
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: 100
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.bottomRight:Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: message.isUser ? Colors.blueAccent : Colors.greenAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          message.text,
                          style: const TextStyle(
                              color: Colors.black),
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
              color: Colors
                  .white,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: const TextStyle(
                            color: Colors.black54),
                        filled: true,
                        fillColor: Colors
                            .white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple, width: 4.0),
                        ),
                      ),
                      style: const TextStyle(
                          color: Colors.black),
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
                      // Implementación del botón de micrófono
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

  Future<void> _callApi(String userMessage) async {
    //TODO: Cambiar a inyection?
    ApiService apiService = new ApiService();
    final userPrompt = userMessage.isEmpty ? null : userMessage;
    final apiPrompt = apiService.getTopicPrompt("English", userPrompt: userPrompt);
    final response = await apiService.geminiApiCall(apiPrompt);

    final Map<String, dynamic> decodedData = json.decode(response);
    final apiMessage = decodedData['message'];

    setState(() {
      _messages.add(Message(text: apiMessage, isUser: false));
    });
  }
}
