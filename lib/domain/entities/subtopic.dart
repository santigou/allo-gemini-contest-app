class Subtopic {
  int? id;
  String name;
  String description;
  String objectives;
  String summary;
  bool completed;
  int order;
  bool isUnlocked;
  int topicId; // Clave foránea al tema

  Subtopic({
    this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.summary,
    required this.completed,
    required this.order,
    required this.isUnlocked,
    required this.topicId,
  });

  factory Subtopic.fromMap(Map<String, dynamic> map) => Subtopic(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      objectives: map['objectives'] as String,
      summary: map['summary'] as String,
      completed: map['completed'] == 1, // Convert integer back to boolean
      order: map['topicOrder'] as int,
      isUnlocked: (map['isUnlocked'] as int) == 1,
      topicId: map['topicId'] as int,
  );
}
