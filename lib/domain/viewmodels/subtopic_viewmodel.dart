class SubtopicViewmodel
{
  String name;
  String description;
  String objectives;
  String summary;
  int order;

  SubtopicViewmodel({
    required this.name,
    required this.description,
    required this.objectives,
    required this.summary,
    required this.order,
  });
  
  factory SubtopicViewmodel.fromMap(Map<String, dynamic> map) => SubtopicViewmodel(
  name: map['name'] as String,
  description: map['description'] as String,
  objectives: map['objectives'] as String,
  summary: map['summary'] as String,
  order: map['order'] as int
  );

}