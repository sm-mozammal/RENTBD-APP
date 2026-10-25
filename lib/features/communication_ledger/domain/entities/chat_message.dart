import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.createdAt,
    this.isMe = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final bool isMe;

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        message,
        createdAt,
        isMe,
      ];
}
