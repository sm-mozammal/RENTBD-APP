import 'package:dio/dio.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import '../models/call_token_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import 'chat_datasource.dart';

class ChatRemoteDataSource implements ChatDataSource {
  const ChatRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<ChatRoomModel>> getRooms() async {
    try {
      final response = await _dioClient.get('/chat/rooms/');
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => ChatRoomModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch chat rooms: $e');
    }
  }

  @override
  Future<ChatRoomModel> createRoom({
    required String propertyId,
    required String recipientId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/chat/rooms/',
        data: {
          'property_id': propertyId,
          'recipient_id': recipientId,
        },
      );
      return ChatRoomModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to create chat room: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId) async {
    try {
      final response = await _dioClient.get('/chat/rooms/$roomId/messages/');
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch messages: $e');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String roomId, String message) async {
    try {
      final response = await _dioClient.post(
        '/chat/rooms/$roomId/messages/',
        data: {'message': message},
      );
      return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to send message: $e');
    }
  }

  @override
  Future<CallTokenModel> getCallToken(String roomId) async {
    try {
      final response = await _dioClient.post('/chat/rooms/$roomId/call-token/');
      return CallTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to generate calling token: $e');
    }
  }
}
