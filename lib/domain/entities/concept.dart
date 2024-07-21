class Concept {
  int id;
  String name;
  String explanation;
  String examples;
  String subtopicId; // Clave foránea al subtema

  Concept({
    required this.id,
    required this.name,
    required this.explanation,
    required this.examples,
    required this.subtopicId,
  });

}
