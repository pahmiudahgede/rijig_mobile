import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/chat/presentation/model/chatlist_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatItem> _allChats = [];
  List<ChatItem> _filteredChats = [];
  bool _isSearching = false;

  // Selection mode states
  bool _isSelectionMode = false;
  Set<String> _selectedChatIds = {};

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
    _filteredChats = _allChats;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDummyData() {
    final now = DateTime.now();

    _allChats = [
      ChatItem(
        id: '1',
        name: 'Sarah Johnson',
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b793?w=150',
        lastMessage: 'Halo! Bagaimana dengan projek yang kemarin?',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 3,
        isOnline: true,
      ),
      ChatItem(
        id: '2',
        name: 'Ahmad Pratama',
        profileImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        lastMessage: 'Terima kasih untuk bantuannya!',
        lastMessageTime: now.subtract(const Duration(minutes: 15)),
        unreadCount: 1,
        isOnline: true,
      ),
      ChatItem(
        id: '3',
        name: 'Maria Garcia',
        profileImage:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        lastMessage: 'Sudah sampai rumah dengan selamat',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: 0,
        isOnline: false,
      ),
      ChatItem(
        id: '4',
        name: 'David Chen',
        profileImage:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        lastMessage: 'Baik, nanti saya kirim file nya',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 2,
        isOnline: true,
      ),
      ChatItem(
        id: '5',
        name: 'Jessica Lee',
        profileImage:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        lastMessage: 'Kapan kita bisa ketemu lagi?',
        lastMessageTime: now.subtract(const Duration(hours: 4)),
        unreadCount: 0,
        isOnline: true,
      ),
      ChatItem(
        id: '6',
        name: 'Michael Rodriguez',
        profileImage:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        lastMessage: 'Jangan lupa meeting besok pagi',
        lastMessageTime: now.subtract(const Duration(hours: 8)),
        unreadCount: 4,
        isOnline: false,
      ),
      ChatItem(
        id: '7',
        name: 'Lisa Wang',
        profileImage:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        lastMessage: 'Foto-fotonya bagus banget!',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
      ),
      ChatItem(
        id: '8',
        name: 'Ryan Thompson',
        profileImage:
            'https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?w=150',
        lastMessage: 'Oke siap, sampai jumpa!',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        unreadCount: 1,
        isOnline: false,
      ),
    ];
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredChats = _allChats;
      } else {
        _filteredChats =
            _allChats.where((chat) {
              return chat.name.toLowerCase().contains(query) ||
                  chat.lastMessage.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _onChatTap(ChatItem chat) {
    if (_isSelectionMode) {
      // Toggle selection in selection mode
      setState(() {
        if (_selectedChatIds.contains(chat.id)) {
          _selectedChatIds.remove(chat.id);
        } else {
          _selectedChatIds.add(chat.id);
        }

        // Exit selection mode if no items selected
        if (_selectedChatIds.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      // Normal navigation
      // Mark as read (remove unread count)
      setState(() {
        final index = _allChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          _allChats[index] = ChatItem(
            id: chat.id,
            name: chat.name,
            profileImage: chat.profileImage,
            lastMessage: chat.lastMessage,
            lastMessageTime: chat.lastMessageTime,
            unreadCount: 0, // Mark as read
            isOnline: chat.isOnline,
          );
          _filteredChats = _allChats;
        }
      });

      // Navigate to chat room with query parameters
      final encodedName = Uri.encodeComponent(chat.name);
      final encodedImage = Uri.encodeComponent(chat.profileImage);
      final onlineStatus = chat.isOnline.toString();

      router.push(
        '/chatroom/${chat.id}?name=$encodedName&image=$encodedImage&online=$onlineStatus',
      );
    }
  }

  void _onChatLongPress(ChatItem chat) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedChatIds.add(chat.id);
      });
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedChatIds.clear();
    });
  }

  void _selectAllChats() {
    setState(() {
      _selectedChatIds = _filteredChats.map((chat) => chat.id).toSet();
    });
  }

  void _markSelectedAsRead() {
    final selectedCount = _selectedChatIds.length;

    setState(() {
      for (int i = 0; i < _allChats.length; i++) {
        if (_selectedChatIds.contains(_allChats[i].id)) {
          _allChats[i] = ChatItem(
            id: _allChats[i].id,
            name: _allChats[i].name,
            profileImage: _allChats[i].profileImage,
            lastMessage: _allChats[i].lastMessage,
            lastMessageTime: _allChats[i].lastMessageTime,
            unreadCount: 0, // Mark as read
            isOnline: _allChats[i].isOnline,
          );
        }
      }
      _filteredChats = _allChats;
      _exitSelectionMode();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$selectedCount chat ditandai sudah dibaca'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _deleteSelectedChats() {
    final selectedCount = _selectedChatIds.length;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Hapus Chat'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus $selectedCount chat? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _allChats.removeWhere(
                      (chat) => _selectedChatIds.contains(chat.id),
                    );
                    _filteredChats = _allChats;
                    _exitSelectionMode();
                  });

                  context.pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$selectedCount chat berhasil dihapus'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _allChats.length; i++) {
        _allChats[i] = ChatItem(
          id: _allChats[i].id,
          name: _allChats[i].name,
          profileImage: _allChats[i].profileImage,
          lastMessage: _allChats[i].lastMessage,
          lastMessageTime: _allChats[i].lastMessageTime,
          unreadCount: 0, // Mark as read
          isOnline: _allChats[i].isOnline,
        );
      }
      _filteredChats = _allChats;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua chat ditandai sudah dibaca'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _deleteAllChats() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Hapus Semua Chat'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua chat? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _allChats.clear();
                    _filteredChats.clear();
                  });

                  context.pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Semua chat berhasil dihapus'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUnread = _allChats.fold<int>(
      0,
      (sum, chat) => sum + chat.unreadCount,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading:
            _isSelectionMode
                ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
        title:
            _isSelectionMode
                ? Text(
                  '${_selectedChatIds.length} dipilih',
                  style: Tulisan.subheading(),
                )
                : Column(
                  children: [
                    Text('Chat', style: Tulisan.subheading()),
                    if (totalUnread > 0)
                      Text(
                        '$totalUnread pesan belum dibaca',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
        centerTitle: true,
        actions:
            _isSelectionMode
                ? [
                  // Select All Button
                  IconButton(
                    icon: Icon(
                      _selectedChatIds.length == _filteredChats.length
                          ? Icons.deselect
                          : Icons.select_all,
                    ),
                    onPressed: () {
                      if (_selectedChatIds.length == _filteredChats.length) {
                        _exitSelectionMode();
                      } else {
                        _selectAllChats();
                      }
                    },
                    tooltip:
                        _selectedChatIds.length == _filteredChats.length
                            ? 'Batal pilih semua'
                            : 'Pilih semua',
                  ),
                  // Mark as Read Button
                  IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    onPressed:
                        _selectedChatIds.isNotEmpty
                            ? _markSelectedAsRead
                            : null,
                    tooltip: 'Tandai sudah dibaca',
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed:
                        _selectedChatIds.isNotEmpty
                            ? _deleteSelectedChats
                            : null,
                    tooltip: 'Hapus',
                  ),
                ]
                : [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_all_read':
                          _markAllAsRead();
                          break;
                        case 'delete_all':
                          _deleteAllChats();
                          break;
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(
                            value: 'mark_all_read',
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.mark_email_read,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text('Baca Semua'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete_all',
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.delete_sweep,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus Semua Chat',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: whiteColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari chat atau pesan...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon:
                    _isSearching
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child:
                _filteredChats.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredChats.length,
                      itemBuilder: (context, index) {
                        return _buildChatItem(_filteredChats[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching ? 'Tidak ada chat ditemukan' : 'Belum ada chat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching ? 'Coba kata kunci lain' : 'Belum ada percakapan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatItem chat) {
    final isSelected = _selectedChatIds.contains(chat.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.1) : whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onChatTap(chat),
          onLongPress: () => _onChatLongPress(chat),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Selection Checkbox (only show in selection mode)
                if (_isSelectionMode) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? primaryColor : Colors.transparent,
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                ],

                // Profile Picture with Online Status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: NetworkImage(chat.profileImage),
                      onBackgroundImageError: (_, __) {},
                      child: Text(
                        chat.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (chat.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: whiteColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // Chat Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    chat.unreadCount > 0
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(chat.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  chat.unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  chat.unreadCount > 0
                                      ? primaryColor
                                      : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Last Message and Unread Count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    chat.unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                color:
                                    chat.unreadCount > 0
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(minWidth: 20),
                              child: Text(
                                chat.unreadCount > 99
                                    ? '99+'
                                    : '${chat.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
