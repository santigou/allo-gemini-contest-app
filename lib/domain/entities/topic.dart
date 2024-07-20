class Topic {
  String id;
  String name;
  String description;
  String objectives;
  String languageId;
  String summary;
  int subtopicCount;

  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.languageId,
    required this.summary,
    required this.subtopicCount,
  });

  factory Topic.fromSqfliteDatabase(Map<String, dynamic> map) => Topic(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      objectives: map['objectives'] as String,
      languageId: map['languageId'] as String,
      summary: map['summary'] as String,
      subtopicCount: map['subtopicCount'] as int,
    );
}
