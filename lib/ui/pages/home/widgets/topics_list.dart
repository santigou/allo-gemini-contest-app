import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/topic.dart';
import '../../../../domain/services/topic_service.dart';

//TODO ADJUST STYLES
//TODO DOESNT SHOW CHANGES WHEN RETURNED
class TopicsList extends StatelessWidget {
  final TopicService topicService;
  final int? languageId; // Puedes pasar el ID del idioma si es necesario

  const TopicsList({Key? key, required this.topicService, this.languageId}) : super(key: key);

  Future<List<Topic>> _fetchTopics() async {
    return await topicService.getAllTopics(languageId: languageId);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Topic>>(
        future: _fetchTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No topics available"));
          }

          final topics = snapshot.data!;
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Text(topic.name),
                subtitle: Text(topic.description),
                // TODO ADD ONTAP
              );
            },
          );
        },
      ),
    );
  }
}
