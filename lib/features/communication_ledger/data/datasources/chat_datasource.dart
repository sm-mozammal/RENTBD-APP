import '../models/call_token_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatDataSource {
  Future<List<ChatRoomModel>> getRooms();
  Future<ChatRoomModel> createRoom({required String propertyId, required String recipientId});
  Future<List<ChatMessageModel>> getMessages(String roomId);
  Future<ChatMessageModel> sendMessage(String roomId, String message);
  Future<CallTokenModel> getCallToken(String roomId);
}
