class ChatMessage {
  int? id;
  String message;
  String role;
  int subtopicId;

  ChatMessage({
    this.id,
    required this.message,
    required this.role,
    required this.subtopicId,
  });

  factory ChatMessage.fromSqfliteDatabase(Map<String, dynamic> map) => ChatMessage(
      id: map['id'] as int,
      message: map['message'] as String,
      role: map['role'] as String,
      subtopicId: map['subtopicId'] as int);
}