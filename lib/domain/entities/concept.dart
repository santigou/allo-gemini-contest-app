class Concept {
  int? id;
  String name;
  String explanation;
  String examples;
  int messageId; // Clave foránea al subtema

  Concept({
    this.id,
    required this.name,
    required this.explanation,
    required this.examples,
    required this.messageId,
  });

  factory Concept.fromSqfliteDatabase(Map<String, dynamic> map) => Concept(
      id: map['id'] as int,
      name: map['name'] as String,
      explanation: map['explanation'] as String,
      examples: map['examples'] as String,
      messageId: map['messageId'] as int,
  );
}
