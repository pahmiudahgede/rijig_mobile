class ChatItem {
  final String id;
  final String name;
  final String profileImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatItem({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}