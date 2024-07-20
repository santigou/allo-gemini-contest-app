class Subtopic {
  String id;
  String name;
  String description;
  String objectives;
  String summary;
  int conceptCount;
  bool completed;
  String? previousSubtopicId; // Clave foránea al subtema anterior
  String?
  nextSubtopicId; // Clave foránea al subtema siguiente
  String topicId; // Clave foránea al tema

  Subtopic({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.summary,
    required this.conceptCount,
    required this.completed,
    this.previousSubtopicId,
    this.nextSubtopicId,
    required this.topicId,
  });

  factory Subtopic.fromMap(Map<String, dynamic> map) => Subtopic(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      objectives: map['objectives'] as String,
      summary: map['summary'] as String,
      conceptCount: map['conceptCount'] as int,
      completed: map['completed'] == 1, // Convert integer back to boolean
      previousSubtopicId: map['previousSubtopicId'] as String?,
      nextSubtopicId: map['nextSubtopicId'] as String?,
      topicId: map['topicId'] as String,
    );
}
