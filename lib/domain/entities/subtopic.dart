class Subtopic {
  int? id;
  String name;
  String description;
  String objectives;
  String summary;
  int conceptCount;
  bool completed;
  int order;
  int topicId; // Clave foránea al tema

  Subtopic({
    this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.summary,
    required this.conceptCount,
    required this.completed,
    required this.order,
    required this.topicId,
  });

  factory Subtopic.fromMap(Map<String, dynamic> map) => Subtopic(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      objectives: map['objectives'] as String,
      summary: map['summary'] as String,
      conceptCount: map['conceptCount'] ?? 0,
      completed: map['completed'] == 1, // Convert integer back to boolean
      order: map['topicOrder'] as int,
      topicId: map['topicId'] as int,
  );
}
