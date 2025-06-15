import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<NotificationItem> unreadNotifications = [
    NotificationItem(
      id: '1',
      title: 'Pesanan Dikonfirmasi',
      message: 'Pesanan #12345 telah dikonfirmasi dan sedang diproses',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.order,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Promo Spesial!',
      message: 'Dapatkan diskon 50% untuk pembelian minimal Rp 100.000',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.promotion,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Pengiriman Dalam Perjalanan',
      message: 'Pesanan #12344 sedang dalam perjalanan menuju alamat Anda',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      type: NotificationType.delivery,
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Update Sistem',
      message: 'Aplikasi telah diperbarui dengan fitur-fitur terbaru',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.system,
      isRead: false,
    ),
    NotificationItem(
      id: '5',
      title: 'Pembayaran Berhasil',
      message: 'Pembayaran untuk pesanan #12343 telah berhasil diproses',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      type: NotificationType.payment,
      isRead: false,
    ),
  ];

  List<NotificationItem> readNotifications = [
    NotificationItem(
      id: '6',
      title: 'Pesanan Selesai',
      message:
          'Pesanan #12342 telah selesai. Berikan rating untuk pelayanan kami!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.order,
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      title: 'Cashback Berhasil',
      message: 'Cashback sebesar Rp 10.000 telah masuk ke saldo Anda',
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.payment,
      isRead: true,
    ),
    NotificationItem(
      id: '8',
      title: 'Selamat Datang!',
      message: 'Terima kasih telah bergabung dengan aplikasi kami',
      time: DateTime.now().subtract(const Duration(days: 7)),
      type: NotificationType.system,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in unreadNotifications) {
        notification.isRead = true;
        readNotifications.insert(0, notification);
      }
      unreadNotifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua notifikasi telah ditandai sebagai dibaca'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
      unreadNotifications.remove(notification);
      readNotifications.insert(0, notification);
    });
  }

  void _deleteNotification(NotificationItem notification, bool isFromUnread) {
    setState(() {
      if (isFromUnread) {
        unreadNotifications.remove(notification);
      } else {
        readNotifications.remove(notification);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi telah dihapus'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text('Notifikasi', style: Tulisan.subheading()),
        centerTitle: true,
        actions: [
          if (unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Baca Semua',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey.shade100,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum Dibaca'),
                        if (unreadNotifications.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${unreadNotifications.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Dibaca'),
                        if (readNotifications.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${readNotifications.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUnreadTab(), _buildReadTab()],
      ),
    );
  }

  Widget _buildUnreadTab() {
    if (unreadNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_off,
        title: 'Tidak Ada Notifikasi Baru',
        subtitle: 'Semua notifikasi sudah dibaca',
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unreadNotifications.length,
        itemBuilder: (context, index) {
          final notification = unreadNotifications[index];
          return _buildNotificationCard(notification, true);
        },
      ),
    );
  }

  Widget _buildReadTab() {
    if (readNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_email_read,
        title: 'Belum Ada Notifikasi Dibaca',
        subtitle: 'Notifikasi yang sudah dibaca akan muncul di sini',
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: readNotifications.length,
        itemBuilder: (context, index) {
          final notification = readNotifications[index];
          return _buildNotificationCard(notification, false);
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, bool isUnread) {
    final notificationIcon = _getNotificationIcon(notification.type);
    final notificationColor = _getNotificationColor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border:
            isUnread
                ? Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                )
                : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 24),
        ),
        onDismissed: (direction) {
          _deleteNotification(notification, isUnread);
        },
        child: InkWell(
          onTap: isUnread ? () => _markAsRead(notification) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notificationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notificationIcon,
                    color: notificationColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isUnread
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                color:
                                    isUnread
                                        ? Colors.black
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isUnread
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(notification.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const Spacer(),
                          _buildNotificationTypeChip(notification.type),
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

  Widget _buildNotificationTypeChip(NotificationType type) {
    String label;
    Color color;

    switch (type) {
      case NotificationType.order:
        label = 'Pesanan';
        color = Colors.blue;
        break;
      case NotificationType.delivery:
        label = 'Pengiriman';
        color = Colors.green;
        break;
      case NotificationType.payment:
        label = 'Pembayaran';
        color = Colors.orange;
        break;
      case NotificationType.promotion:
        label = 'Promo';
        color = Colors.purple;
        break;
      case NotificationType.system:
        label = 'Sistem';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.delivery:
        return Icons.local_shipping;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.delivery:
        return Colors.green;
      case NotificationType.payment:
        return Colors.orange;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

enum NotificationType { order, delivery, payment, promotion, system }
