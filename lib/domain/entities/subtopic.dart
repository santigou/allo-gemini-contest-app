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
}
