import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.createdAt,
    this.isMe = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id'] as String? ?? '';
    final isMe = currentUserId != null
        ? senderId == currentUserId
        : (json['is_me'] as bool? ?? false);

    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      senderId: senderId,
      senderName: json['sender_name'] as String? ?? 'User',
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      isMe: isMe,
    );
  }

  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final bool isMe;

  Map<String, dynamic> toJson() => {
        'message': message,
      };

  ChatMessage toEntity() => ChatMessage(
        id: id,
        senderId: senderId,
        senderName: senderName,
        message: message,
        createdAt: createdAt,
        isMe: isMe,
      );
}
