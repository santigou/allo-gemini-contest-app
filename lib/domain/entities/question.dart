import 'package:flutter/cupertino.dart';

class Question {
  int id;
  String questionDescription;
  String possibleAnswer;
  String subtopicId;

  Question({
    required this.id,
    required this.questionDescription,
    required this.possibleAnswer,
    required this.subtopicId,
  });
}
