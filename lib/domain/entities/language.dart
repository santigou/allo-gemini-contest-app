class Language {
  String id;
  String name;
  String image;

  Language({required this.id, required this.name, required this.image});

  factory Language.fromSqfliteDatabase(Map<String, dynamic> map) => Language(
      id: map['id']??"",
      name: map['name']??"",
      image: map['image']??"");
}
