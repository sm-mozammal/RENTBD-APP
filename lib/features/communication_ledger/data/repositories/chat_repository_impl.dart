import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import '../../domain/entities/call_token.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
  });

  final ChatDataSource mockDataSource;
  final ChatDataSource remoteDataSource;

  ChatDataSource get _activeDataSource =>
      AppEnvironment.useMockData ? mockDataSource : remoteDataSource;

  @override
  Future<List<ChatRoom>> getRooms() async {
    try {
      final models = await _activeDataSource.getRooms();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<ChatRoom> createRoom({
    required String propertyId,
    required String recipientId,
  }) async {
    try {
      final model = await _activeDataSource.createRoom(
        propertyId: propertyId,
        recipientId: recipientId,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      final models = await _activeDataSource.getMessages(roomId);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<ChatMessage> sendMessage(String roomId, String message) async {
    try {
      final model = await _activeDataSource.sendMessage(roomId, message);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<CallToken> getCallToken(String roomId) async {
    try {
      final model = await _activeDataSource.getCallToken(roomId);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
