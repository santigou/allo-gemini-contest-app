import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/entities/subtopic.dart';
import '../../../../domain/entities/topic.dart';
import '../../../../domain/services/subtopic_service.dart';
import '../../../../domain/services/topic_service.dart';
import '../../playground/steps_screen.dart';

import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/services/chat_message_service.dart';
import 'package:gemini_proyect/domain/services/concept_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/entities/subtopic.dart';
import '../../../../domain/entities/topic.dart';
import '../../../../domain/services/subtopic_service.dart';
import '../../../../domain/services/topic_service.dart';
import '../../playground/steps_screen.dart';

class TopicsList extends StatefulWidget {
  final TopicService topicService;
  final SubtopicService subtopicService;
  final IChatMessageService chatMessageService;
  final ConceptService conceptService;
  final ValueNotifier<int> languageNotifier;
  final ValueNotifier<List<Topic>> topicsNotifier;

  const TopicsList({
    Key? key,
    required this.topicService,
    required this.subtopicService,
    required this.chatMessageService,
    required this.conceptService,
    required this.languageNotifier,
    required this.topicsNotifier,
  }) : super(key: key);

  @override
  _TopicsListState createState() => _TopicsListState();
}

class _TopicsListState extends State<TopicsList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    widget.languageNotifier.addListener(_fetchTopics);
  }

  @override
  void dispose() {
    widget.languageNotifier.removeListener(_fetchTopics);
    super.dispose();
  }

  void _fetchTopics() async {
    int languageId = widget.languageNotifier.value;
    List<Topic> topics = await widget.topicService.getAllTopics(languageId: languageId);
    widget.topicsNotifier.value = topics;
  }

  Future<void> _navigateToSteps(Topic topic) async {
    List<Subtopic> subtopics = await widget.subtopicService.getSubtopicsByTopicId(topic.id!);
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("topicLevel", topic.level);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StepsScreen(
          steps: subtopics,
          classTopicName: topic.name,
          chatMessageService: widget.chatMessageService,
          conceptService: widget.conceptService,
          subtopicService: widget.subtopicService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Topic>>(
      valueListenable: widget.topicsNotifier,
      builder: (context, topics, _) {
        if (topics.isEmpty) {
          return const Center(child: Text("No topics available"));
        }

        return ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0).copyWith(bottom: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(topic.name),
                subtitle: Text(topic.description),
                onTap: () => _navigateToSteps(topic),
              ),
            );
          },
        );
      },
    );
  }
}
