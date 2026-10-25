import '../entities/call_token.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getRooms();
  Future<ChatRoom> createRoom({required String propertyId, required String recipientId});
  Future<List<ChatMessage>> getMessages(String roomId);
  Future<ChatMessage> sendMessage(String roomId, String message);
  Future<CallToken> getCallToken(String roomId);
}
