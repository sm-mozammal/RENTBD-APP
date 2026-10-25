import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  const ChatRoom({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.recipientId,
    required this.recipientName,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String id;
  final String propertyId;
  final String propertyTitle;
  final String recipientId;
  final String recipientName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyTitle,
        recipientId,
        recipientName,
        lastMessage,
        lastMessageTime,
        unreadCount,
      ];
}
