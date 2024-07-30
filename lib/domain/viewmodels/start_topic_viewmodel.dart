import 'package:gemini_proyect/domain/viewmodels/subtopic_viewmodel.dart';

class startTopicViewModel{
  String name;
  String description;
  String objectives;
  String summary;
  int level;
  List<SubtopicViewmodel> subtopics;

  startTopicViewModel({
    required this.name,
    required this.description,
    required this.objectives,
    required this.summary,
    required this.level,
    required this.subtopics
  });

  factory startTopicViewModel.fromMap(Map<String, dynamic> map) => startTopicViewModel(
      name: map['name'] as String,
      description: map['description'] as String,
      objectives: map['objectives'] as String,
      summary: map['summary'] as String,
      level: map['level'] as int,
      subtopics: (map['subtopics'] as List<dynamic>)
          .map((subtopicMap) => SubtopicViewmodel.fromMap(subtopicMap))
          .toList(),
    );
}