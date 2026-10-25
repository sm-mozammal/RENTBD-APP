import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';

class _Message {
  _Message({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;
}

/// In-App Masked Chat & Encrypted Voice Calling simulator screen.
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.chatId});

  final String chatId;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final List<_Message> _messages = [
    _Message(
      text: 'Assalamu Alaikum. Is the 2-bed flat near Mirpur 10 Metro still available for bachelor engineers?',
      isMe: true,
      time: '10:14 AM',
    ),
    _Message(
      text: 'Walaikum Assalam. Yes, it is available from 1st of next month. Water and line gas are continuous 24/7.',
      isMe: false,
      time: '10:16 AM',
    ),
    _Message(
      text: 'Great! Can we schedule a quick Live Video Tour tomorrow at 4:30 PM?',
      isMe: true,
      time: '10:18 AM',
    ),
    _Message(
      text: 'Certainly! I have accepted your video walkthrough request in the scheduler.',
      isMe: false,
      time: '10:20 AM',
    ),
  ];

  void _onSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _Message(
          text: text,
          isMe: true,
          time: 'Now',
        ),
      );
      _messageController.clear();
    });
  }

  void _onMaskedAudioCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Masked Voice Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your real phone number is protected (+880 17•• ••••23). Calls are routed through RentBD encrypted bridge.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Zero spam or off-hours calls',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          BariButton(
            label: 'Start Call',
            isFullWidth: false,
            height: 40,
            leadingIcon: const Icon(Icons.call, size: 16, color: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connecting masked call to Engr. Farhan Kabir...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Row(
          children: [
            const BariAvatar(
              name: 'Farhan Kabir',
              radius: 18,
              isVerified: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Engr. Farhan Kabir',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Masked Contact • Verified Landlord',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
            tooltip: 'In-App Masked Voice Call',
            onPressed: _onMaskedAudioCall,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Privacy Shield Notice Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primarySoft,
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'End-to-End Encrypted. Both phone numbers remain 100% hidden.',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: msg.isMe ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
                          bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: AppTypography.bodyMedium.copyWith(
                              color: msg.isMe ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.time,
                            style: AppTypography.labelSmall.copyWith(
                              color: msg.isMe ? Colors.white.withAlpha(180) : AppColors.lightTextMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input field
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.lightBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BariTextField(
                        controller: _messageController,
                        hintText: 'Type a message...',
                        onSubmitted: (_) => _onSendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _onSendMessage,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
