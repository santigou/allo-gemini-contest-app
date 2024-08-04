import 'package:flutter/material.dart';
import 'package:gemini_proyect/data/services/database_service.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
import 'package:gemini_proyect/domain/services/subtopic_service.dart';
import 'package:gemini_proyect/domain/services/topic_service.dart';
import 'domain/services/api_service.dart';
import 'ui/pages/home/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();
  final TopicService topicService = TopicService();
  final SubtopicService subtopicService = SubtopicService();
  final IChatMessageService chatMessageService = ChatMessageService();
  final ConceptService conceptService = ConceptService();
  final DatabaseService databaseService = DatabaseService.instance;
  MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(
        apiService: apiService,
        topicService: topicService,
        databaseService: databaseService,
        subtopicService: subtopicService,
        chatMessageService: chatMessageService,
        conceptService: conceptService,),
      debugShowCheckedModeBanner: false,
    );
  }
}