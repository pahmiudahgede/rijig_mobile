import 'package:rijig_mobile/features/chat/presentation/screen/chatroom_screen.dart';

class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isFromMe;
  final MessageType type;
  final MessageStatus status;
  final String? mediaUrl;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isFromMe,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.mediaUrl,
  });
}
