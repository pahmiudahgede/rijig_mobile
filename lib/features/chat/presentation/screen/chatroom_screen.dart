import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/chat/presentation/model/chatroom_model.dart';
import 'package:rijig_mobile/widget/custom_bottom_sheet.dart';

// Model untuk Message
/* class Message {
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
} */

enum MessageType { text, image, video }

enum MessageStatus { sending, sent, delivered, read }

class ChatRoomScreen extends StatefulWidget {
  final String contactName;
  final String contactImage;
  final bool isOnline;

  const ChatRoomScreen({
    super.key,
    required this.contactName,
    required this.contactImage,
    this.isOnline = false,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocus = FocusNode();

  List<Message> _messages = [];
  bool _isTyping = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeDummyMessages();
    _messageController.addListener(_onTypingChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _initializeDummyMessages() {
    final now = DateTime.now();

    _messages = [
      Message(
        id: '1',
        content: 'Halo! Bagaimana kabarnya?',
        timestamp: now.subtract(const Duration(hours: 2)),
        isFromMe: false,
        status: MessageStatus.read,
      ),
      Message(
        id: '2',
        content: 'Halo juga! Baik kok, sedang sibuk proyekan',
        timestamp: now.subtract(const Duration(hours: 2, minutes: -5)),
        isFromMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '3',
        content: 'Wah asyik, projek apa emangnya?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        isFromMe: false,
        status: MessageStatus.read,
      ),
      Message(
        id: '4',
        content: 'Projek mobile app untuk client, lumayan challenging sih',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isFromMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '5',
        content:
            'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        isFromMe: false,
        type: MessageType.image,
        status: MessageStatus.read,
        mediaUrl:
            'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400',
      ),
      Message(
        id: '6',
        content: 'Keren banget! UI nya bagus',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 25)),
        isFromMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '7',
        content: 'Terima kasih! Btw kapan kita bisa ketemu lagi?',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isFromMe: false,
        status: MessageStatus.delivered,
      ),
      Message(
        id: '8',
        content: 'Gimana weekend ini? Kita bisa lunch bareng',
        timestamp: now.subtract(const Duration(minutes: 25)),
        isFromMe: true,
        status: MessageStatus.delivered,
      ),
      Message(
        id: '9',
        content: 'Boleh banget! Jam berapa dan dimana?',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isFromMe: false,
        status: MessageStatus.sent,
      ),
    ];
  }

  void _onTypingChanged() {
    final isCurrentlyTyping = _messageController.text.isNotEmpty;
    if (isCurrentlyTyping != _isTyping) {
      setState(() {
        _isTyping = isCurrentlyTyping;
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      timestamp: DateTime.now(),
      isFromMe: true,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simulate sending
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSending = false;
        // Update message status to sent
        final index = _messages.indexWhere((m) => m.id == newMessage.id);
        if (index != -1) {
          _messages[index] = Message(
            id: newMessage.id,
            content: newMessage.content,
            timestamp: newMessage.timestamp,
            isFromMe: newMessage.isFromMe,
            status: MessageStatus.sent,
          );
        }
      });

      // Simulate delivery after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == newMessage.id);
          if (index != -1) {
            _messages[index] = Message(
              id: newMessage.id,
              content: newMessage.content,
              timestamp: newMessage.timestamp,
              isFromMe: newMessage.isFromMe,
              status: MessageStatus.delivered,
            );
          }
        });
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    CustomBottomSheet.show(
      context: context,
      title: 'Kirim Media',
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            label: 'Kamera',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          _buildAttachmentOption(
            icon: Icons.photo_library,
            label: 'Galeri',
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
          ),
          _buildAttachmentOption(
            icon: Icons.videocam,
            label: 'Video',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _pickVideo();
            },
          ),
        ],
      ),
      button1: Container(), // Empty since we have custom buttons
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _takePhoto() {
    debugPrint('Take photo from camera');
    // Example: ImagePicker.pickImage(source: ImageSource.camera)
  }

  void _pickFromGallery() {
    debugPrint('Pick image from gallery');
    // Example: ImagePicker.pickImage(source: ImageSource.gallery)
  }

  void _pickVideo() {
    debugPrint('Pick video from gallery');
    // Example: ImagePicker.pickVideo(source: ImageSource.gallery)
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: Colors.grey.shade500);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: Colors.grey.shade500);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 14, color: primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(widget.contactImage),
                  onBackgroundImageError: (_, __) {},
                  child: Text(
                    widget.contactName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (widget.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: whiteColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    widget.isOnline ? 'Online' : 'Terakhir dilihat baru saja',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              debugPrint('Show chat options');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showTimestamp =
                    index == 0 ||
                    _messages[index - 1].timestamp
                            .difference(message.timestamp)
                            .inMinutes
                            .abs() >
                        5;

                return Column(
                  children: [
                    if (showTimestamp)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _formatMessageTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    _buildMessageBubble(message),
                  ],
                );
              },
            ),
          ),

          // Message Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment Button
                  GestureDetector(
                    onTap: _showAttachmentOptions,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.attach_file,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocus,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Send Button
                  GestureDetector(
                    onTap: _isTyping && !_isSending ? _sendMessage : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isTyping ? primaryColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          _isSending
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                Icons.send,
                                color:
                                    _isTyping
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                size: 18,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.isFromMe;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(widget.contactImage),
              onBackgroundImageError: (_, __) {},
              child: Text(
                widget.contactName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? primaryColor : whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image &&
                      message.mediaUrl != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.mediaUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                      ),
                    ),

                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : Colors.black87,
                        height: 1.3,
                      ),
                    ),

                  if (isMe) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMessageTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildMessageStatusIcon(message.status),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
