import 'package:rentbd_app/core/config/app_environment.dart';
import '../models/call_token_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import 'chat_datasource.dart';

class ChatMockDataSource implements ChatDataSource {
  final List<ChatRoomModel> _rooms = [
    ChatRoomModel(
      id: 'room-01',
      propertyId: 'prop-mirpur-01',
      propertyTitle: 'Sunlit 2-BHK Bachelor Apartment',
      recipientId: 'usr-landlord-01',
      recipientName: 'Engr. Farhan Kabir',
      lastMessage: 'Certainly! I have accepted your video walkthrough request in the scheduler.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 54)),
      unreadCount: 0,
    ),
  ];

  final Map<String, List<ChatMessageModel>> _roomMessages = {
    'room-01': [
      ChatMessageModel(
        id: 'msg-01',
        senderId: 'curr-user',
        senderName: 'You',
        message: 'Assalamu Alaikum. Is the 2-bed flat near Mirpur 10 Metro still available for bachelor engineers?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        isMe: true,
      ),
      ChatMessageModel(
        id: 'msg-02',
        senderId: 'usr-landlord-01',
        senderName: 'Engr. Farhan Kabir',
        message: 'Walaikum Assalam. Yes, it is available from 1st of next month. Water and line gas are continuous 24/7.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 8)),
        isMe: false,
      ),
      ChatMessageModel(
        id: 'msg-03',
        senderId: 'curr-user',
        senderName: 'You',
        message: 'Great! Can we schedule a quick Live Video Tour tomorrow at 4:30 PM?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
        isMe: true,
      ),
      ChatMessageModel(
        id: 'msg-04',
        senderId: 'usr-landlord-01',
        senderName: 'Engr. Farhan Kabir',
        message: 'Certainly! I have accepted your video walkthrough request in the scheduler.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 54)),
        isMe: false,
      ),
    ],
  };

  @override
  Future<List<ChatRoomModel>> getRooms() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return List.from(_rooms);
  }

  @override
  Future<ChatRoomModel> createRoom({
    required String propertyId,
    required String recipientId,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final existing = _rooms.where((r) => r.propertyId == propertyId).firstOrNull;
    if (existing != null) return existing;

    final newRoom = ChatRoomModel(
      id: 'room-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      propertyTitle: 'Rental Apartment',
      recipientId: recipientId,
      recipientName: 'Landlord / Host',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );
    _rooms.insert(0, newRoom);
    _roomMessages[newRoom.id] = [];
    return newRoom;
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return List.from(_roomMessages[roomId] ?? _roomMessages['room-01'] ?? []);
  }

  @override
  Future<ChatMessageModel> sendMessage(String roomId, String message) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final msg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'curr-user',
      senderName: 'You',
      message: message,
      createdAt: DateTime.now(),
      isMe: true,
    );
    _roomMessages.putIfAbsent(roomId, () => []).add(msg);
    return msg;
  }

  @override
  Future<CallTokenModel> getCallToken(String roomId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return CallTokenModel(
      sessionId: 'call-session-${DateTime.now().millisecondsSinceEpoch}',
      channelName: 'rentbd_${roomId}_channel',
      rtcToken: '006abec41f4871...agora_token_demo',
      callerRole: 'tenant',
      maskedDisplayName: 'Verified Tenant',
      expiresInSeconds: 3600,
    );
  }
}
