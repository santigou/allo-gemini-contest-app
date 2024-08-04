import '../../domain/entities/chat_message.dart';
import '../services/database_service.dart';

class ChatMessageDao {

  Future<List<ChatMessage>> getAllChatMessages() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM chatMessage ORDER BY id ASC');
    return List.generate(maps.length, (i) {
      return ChatMessage.fromSqfliteDatabase(maps[i]);
    });
  }

  Future<ChatMessage?> getChatMessageById(int id) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM chatMessage WHERE id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return ChatMessage.fromSqfliteDatabase(maps.first);
    }
    return null;
  }

  Future<int> insertChatMessage(ChatMessage chatMessage) async {
    final db = await DatabaseService.instance.database;
    return await db.rawInsert(
      'INSERT INTO chatMessage(message, role, subtopicId) VALUES(?, ?, ?)',
      [
        chatMessage.message,
        chatMessage.role,
        chatMessage.subtopicId,
      ],
    );
  }

  Future<void> updateChatMessage(ChatMessage chatMessage) async {
    final db = await DatabaseService.instance.database;
    await db.rawUpdate(
      'UPDATE chatMessage SET message = ?, role = ?, subtopicId = ? WHERE id = ?',
      [
        chatMessage.message,
        chatMessage.role,
        chatMessage.subtopicId,
        chatMessage.id,
      ],
    );
  }

  Future<void> deleteChatMessage(int id) async {
    final db = await DatabaseService.instance.database;
    await db.rawDelete(
      'DELETE FROM chatMessage WHERE id = ?',
      [id],
    );
  }

  Future<List<ChatMessage>> getChatMessagesBySubtopicId(int subtopicId) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM chatMessage WHERE subtopicId = ? ORDER BY id ASC',
      [subtopicId],
    );
    return List.generate(maps.length, (i) {
      return ChatMessage.fromSqfliteDatabase(maps[i]);
    });
  }
}
