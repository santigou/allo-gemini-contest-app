import 'package:flutter/material.dart';

import '../../../../domain/entities/subtopic.dart';
import '../../../../domain/entities/topic.dart';
import '../../../../domain/services/subtopic_service.dart';
import '../../../../domain/services/topic_service.dart';
import '../../playground/steps_screen.dart';

class TopicsList extends StatefulWidget {
  final TopicService topicService;
  final SubtopicService subtopicService;
  final int languageId;

  const TopicsList({
    Key? key,
    required this.topicService,
    required this.subtopicService,
    required this.languageId,
  }) : super(key: key);

  @override
  _TopicsListState createState() => _TopicsListState();
}

class _TopicsListState extends State<TopicsList> {
  late Future<List<Topic>> _futureTopics;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  void _fetchTopics() {
    setState(() {
      _futureTopics = widget.topicService.getAllTopics(languageId: widget.languageId);
    });
  }

  @override
  void didUpdateWidget(covariant TopicsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.languageId != oldWidget.languageId) {
      _fetchTopics();
    }
  }

  Future<void> _navigateToSteps(Topic topic) async {
    List<Subtopic> subtopics = await widget.subtopicService.getSubtopicsByTopicId(topic.id!);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StepsScreen(
          steps: subtopics,
          classTopicName: topic.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
      future: _futureTopics,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No topics available"));
        }

        final topics = snapshot.data!;
        return Expanded(
          child: ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Text(topic.name),
                subtitle: Text(topic.description),
                onTap: () => _navigateToSteps(topic),
              );
            },
          ),
        );
      },
    );
  }
}
