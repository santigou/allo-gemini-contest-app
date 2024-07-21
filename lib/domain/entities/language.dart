class Language {
  int id;
  String name;
  String image;

  Language({required this.id, required this.name, required this.image});

  factory Language.fromSqfliteDatabase(Map<String, dynamic> map) => Language(
      id: map['id'] as int,
      name: map['name'] as String,
      image: map['image'] as String);
}
