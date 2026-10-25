import '../../domain/entities/chat_room.dart';

class ChatRoomModel {
  const ChatRoomModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.recipientId,
    required this.recipientName,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? json['property'] as String? ?? '',
      propertyTitle: json['property_title'] as String? ?? 'Rental Property',
      recipientId: json['recipient_id'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? 'Host / Tenant',
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  final String id;
  final String propertyId;
  final String propertyTitle;
  final String recipientId;
  final String recipientName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'property_id': propertyId,
        'recipient_id': recipientId,
      };

  ChatRoom toEntity() => ChatRoom(
        id: id,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        recipientId: recipientId,
        recipientName: recipientName,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: unreadCount,
      );
}
