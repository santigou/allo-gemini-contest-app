import 'package:gemini_proyect/data/dao/chat_message_dao.dart';
import 'package:gemini_proyect/domain/entities/chat_message.dart';
import 'package:gemini_proyect/domain/entities/response_model.dart';

abstract class IChatMessageService {
  Future<ResponseModel> createChatMessage(ChatMessage chatMessage);
  Future<List<ChatMessage>> getAllChatMessages();
  Future<ChatMessage?> getChatMessageById(int id);
  Future<ResponseModel> updateChatMessage(ChatMessage chatMessage);
  Future<ResponseModel> deleteChatMessage(int id);
  Future<List<ChatMessage>> getChatMessagesBySubtopicId(int subtopicId);
}

class ChatMessageService implements IChatMessageService {
  final ChatMessageDao _chatMessageDao = ChatMessageDao();

  @override
  Future<ResponseModel> createChatMessage(ChatMessage chatMessage) async {
    try {
      int messageId = await _chatMessageDao.insertChatMessage(chatMessage);
      return ResponseModel(
        isError: false,
        message: "Chat message created successfully",
        result: messageId,
      );
    } on Exception catch (ex) {
      return ResponseModel(
        isError: true,
        message: ex.toString(),
      );
    }
  }

  @override
  Future<List<ChatMessage>> getAllChatMessages() async {
    try {
      List<ChatMessage> messages = await _chatMessageDao.getAllChatMessages();
      return messages;
    } catch (e) {
      print("Error getting chat messages: $e");
      return [];
    }
  }

  @override
  Future<ChatMessage?> getChatMessageById(int id) async {
    try {
      ChatMessage? message = await _chatMessageDao.getChatMessageById(id);
      return message;
    } catch (e) {
      print("Error getting chat message by id: $e");
      return null;
    }
  }

  @override
  Future<ResponseModel> updateChatMessage(ChatMessage chatMessage) async {
    try {
      await _chatMessageDao.updateChatMessage(chatMessage);
      return ResponseModel(
        isError: false,
        message: "Chat message updated successfully",
      );
    } on Exception catch (ex) {
      return ResponseModel(
        isError: true,
        message: ex.toString(),
      );
    }
  }

  @override
  Future<ResponseModel> deleteChatMessage(int id) async {
    try {
      await _chatMessageDao.deleteChatMessage(id);
      return ResponseModel(
        isError: false,
        message: "Chat message deleted successfully",
      );
    } on Exception catch (ex) {
      return ResponseModel(
        isError: true,
        message: ex.toString(),
      );
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessagesBySubtopicId(int subtopicId) async {
    try {
      List<ChatMessage> messages = await _chatMessageDao.getChatMessagesBySubtopicId(subtopicId);
      return messages;
    } catch (e) {
      print("Error getting chat messages by subtopic id: $e");
      return [];
    }
  }
}
