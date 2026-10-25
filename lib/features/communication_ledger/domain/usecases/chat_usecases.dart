import '../entities/call_token.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

class GetChatRoomsUseCase {
  const GetChatRoomsUseCase(this.repository);
  final ChatRepository repository;

  Future<List<ChatRoom>> call() => repository.getRooms();
}

class CreateChatRoomUseCase {
  const CreateChatRoomUseCase(this.repository);
  final ChatRepository repository;

  Future<ChatRoom> call({
    required String propertyId,
    required String recipientId,
  }) =>
      repository.createRoom(
        propertyId: propertyId,
        recipientId: recipientId,
      );
}

class GetChatMessagesUseCase {
  const GetChatMessagesUseCase(this.repository);
  final ChatRepository repository;

  Future<List<ChatMessage>> call(String roomId) => repository.getMessages(roomId);
}

class SendChatMessageUseCase {
  const SendChatMessageUseCase(this.repository);
  final ChatRepository repository;

  Future<ChatMessage> call(String roomId, String message) =>
      repository.sendMessage(roomId, message);
}

class GetAgoraCallTokenUseCase {
  const GetAgoraCallTokenUseCase(this.repository);
  final ChatRepository repository;

  Future<CallToken> call(String roomId) => repository.getCallToken(roomId);
}
