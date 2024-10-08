class Topic {
  int? id;
  String name;
  String description;
  String objectives;
  int languageId;
  String summary;
  int level;
  int subtopicCount;

  Topic({
    this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.languageId,
    required this.summary,
    required this.level,
    required this.subtopicCount,
  });

  factory Topic.fromSqfliteDatabase(Map<String, dynamic> map) => Topic(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      objectives: map['objectives'] as String,
      languageId: map['languageId'] as int,
      level: map['level'] as int,
      summary: map['summary'] as String,
      subtopicCount: map['subtopicCount'] as int,
    );
}
