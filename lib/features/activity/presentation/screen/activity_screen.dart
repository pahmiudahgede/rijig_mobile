import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/tabbar_custom.dart';
import 'package:rijig_mobile/widget/unhope_handler.dart';
import 'package:timelines_plus/timelines_plus.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // Data contoh untuk timeline
  final List<ActivityItem> processActivities = [
    ActivityItem(
      title: 'Pesanan Dikonfirmasi',
      description: 'Pesanan Anda telah dikonfirmasi dan sedang diproses',
      time: '10:30',
      date: '15 Juni 2024',
      status: ActivityStatus.completed,
      icon: Icons.check_circle,
    ),
    ActivityItem(
      title: 'Sedang Disiapkan',
      description: 'Tim kami sedang menyiapkan pesanan Anda',
      time: '11:15',
      date: '15 Juni 2024',
      status: ActivityStatus.inProgress,
      icon: Icons.timer,
    ),
    ActivityItem(
      title: 'Siap Dikirim',
      description: 'Pesanan siap untuk dikirim ke alamat tujuan',
      time: '',
      date: '',
      status: ActivityStatus.pending,
      icon: Icons.local_shipping,
    ),
    ActivityItem(
      title: 'Dalam Perjalanan',
      description: 'Pesanan sedang dalam perjalanan menuju alamat Anda',
      time: '',
      date: '',
      status: ActivityStatus.pending,
      icon: Icons.directions_car,
    ),
    ActivityItem(
      title: 'Pesanan Sampai',
      description: 'Pesanan telah sampai di alamat tujuan',
      time: '',
      date: '',
      status: ActivityStatus.pending,
      icon: Icons.home,
    ),
  ];

  // Data contoh untuk pesanan selesai
  final List<CompletedOrder> completedOrders = [
    CompletedOrder(
      orderId: '#12340',
      title: 'Paket Makanan Premium',
      description: '2x Nasi Gudeg, 1x Es Teh Manis',
      totalAmount: 'Rp 85.000',
      completedDate: '12 Juni 2024',
      completedTime: '14:30',
      rating: 5,
      customerNote: 'Makanan enak sekali, pengiriman cepat!',
    ),
    CompletedOrder(
      orderId: '#12339',
      title: 'Paket Minuman Segar',
      description: '3x Jus Jeruk, 2x Smoothie Mangga',
      totalAmount: 'Rp 65.000',
      completedDate: '10 Juni 2024',
      completedTime: '16:45',
      rating: 4,
      customerNote: 'Minuman segar, kemasan bagus',
    ),
    CompletedOrder(
      orderId: '#12338',
      title: 'Paket Snack Keluarga',
      description: '1x Risoles, 2x Pastel, 1x Kopi',
      totalAmount: 'Rp 45.000',
      completedDate: '8 Juni 2024',
      completedTime: '10:15',
      rating: 5,
      customerNote: '',
    ),
  ];

  // Data contoh untuk pesanan dibatalkan
  final List<CancelledOrder> cancelledOrders = [
    CancelledOrder(
      orderId: '#12337',
      title: 'Paket Lunch Box',
      description: '1x Nasi Ayam Geprek, 1x Es Jeruk',
      totalAmount: 'Rp 35.000',
      cancelledDate: '7 Juni 2024',
      cancelledTime: '13:20',
      cancelReason: 'Dibatalkan oleh pelanggan',
      refundStatus: 'Dikembalikan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: Text('Aktifitas', style: Tulisan.subheading()),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.green.shade100,
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    TabItem(title: 'Proses', count: 6),
                    TabItem(title: 'Selesai', count: 3),
                    TabItem(title: 'Dibatalkan', count: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildProcessTab(),
            _buildCompletedTab(),
            _buildCancelledTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTab() {
    return Container(
      color: Colors.grey.shade50,
      child: completedOrders.isEmpty
          ? Center(child: InfoStateWidget(type: InfoStateType.emptyData))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                final order = completedOrders[index];
                return _buildCompletedOrderCard(order);
              },
            ),
    );
  }

  Widget _buildCompletedOrderCard(CompletedOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Konten pesanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selesai pada ${order.completedDate} • ${order.completedTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.totalAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRatingStars(order.rating),
                ],
              ),
            ],
          ),
          
          // Customer note jika ada
          if (order.customerNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.comment,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Catatan Pelanggan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.customerNote,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Action untuk lihat detail
                  },
                  icon: Icon(
                    Icons.visibility,
                    size: 16,
                    color: primaryColor,
                  ),
                  label: Text(
                    'Lihat Detail',
                    style: TextStyle(color: primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Action untuk pesan lagi
                  },
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Pesan Lagi',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledTab() {
    return Container(
      color: Colors.grey.shade50,
      child: cancelledOrders.isEmpty
          ? Center(child: InfoStateWidget(type: InfoStateType.emptyData))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cancelledOrders.length,
              itemBuilder: (context, index) {
                final order = cancelledOrders[index];
                return _buildCancelledOrderCard(order);
              },
            ),
    );
  }

  Widget _buildCancelledOrderCard(CancelledOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 14,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dibatalkan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Konten pesanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dibatalkan pada ${order.cancelledDate} • ${order.cancelledTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                order.totalAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Info pembatalan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Alasan Pembatalan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.cancelReason,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Status Refund: ${order.refundStatus}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Action untuk pesan lagi
              },
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: primaryColor,
              ),
              label: Text(
                'Pesan Lagi',
                style: TextStyle(color: primaryColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: Colors.orange,
        );
      }),
    );
  }

  Widget _buildProcessTab() {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesanan #12345',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: Rp 150.000',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Dalam Proses',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Timeline Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Timeline.tileBuilder(
      theme: TimelineThemeData(
        nodePosition: 0,
        color: Colors.grey.shade300,
        indicatorTheme: const IndicatorThemeData(
          position: 0,
          size: 20.0,
        ),
        connectorTheme: const ConnectorThemeData(
          thickness: 2.0,
        ),
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      builder: TimelineTileBuilder.connected(
        connectionDirection: ConnectionDirection.before,
        itemCount: processActivities.length,
        contentsBuilder: (context, index) {
          return _buildTimelineContent(processActivities[index]);
        },
        indicatorBuilder: (context, index) {
          return _buildTimelineIndicator(processActivities[index]);
        },
        connectorBuilder: (context, index, type) {
          return SolidLineConnector(
            color: index < processActivities.length - 1 && 
                   processActivities[index].status == ActivityStatus.completed
                ? primaryColor
                : Colors.grey.shade300,
          );
        },
      ),
    );
  }

  Widget _buildTimelineIndicator(ActivityItem item) {
    Color indicatorColor;
    Widget indicatorChild;

    switch (item.status) {
      case ActivityStatus.completed:
        indicatorColor = primaryColor;
        indicatorChild = Icon(
          Icons.check,
          color: Colors.white,
          size: 12,
        );
        break;
      case ActivityStatus.inProgress:
        indicatorColor = Colors.orange;
        indicatorChild = Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
        break;
      case ActivityStatus.pending:
        indicatorColor = Colors.grey.shade300;
        indicatorChild = Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return DotIndicator(
      size: 20,
      color: indicatorColor,
      child: indicatorChild,
    );
  }

  Widget _buildTimelineContent(ActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: item.status == ActivityStatus.completed
                    ? primaryColor
                    : item.status == ActivityStatus.inProgress
                        ? Colors.orange
                        : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: item.status == ActivityStatus.pending
                        ? Colors.grey.shade500
                        : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.status == ActivityStatus.pending
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
                if (item.time.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${item.time} • ${item.date}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Model untuk item aktivitas
class ActivityItem {
  final String title;
  final String description;
  final String time;
  final String date;
  final ActivityStatus status;
  final IconData icon;

  ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.status,
    required this.icon,
  });
}

// Model untuk pesanan selesai
class CompletedOrder {
  final String orderId;
  final String title;
  final String description;
  final String totalAmount;
  final String completedDate;
  final String completedTime;
  final int rating;
  final String customerNote;

  CompletedOrder({
    required this.orderId,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.completedDate,
    required this.completedTime,
    required this.rating,
    required this.customerNote,
  });
}

// Model untuk pesanan dibatalkan
class CancelledOrder {
  final String orderId;
  final String title;
  final String description;
  final String totalAmount;
  final String cancelledDate;
  final String cancelledTime;
  final String cancelReason;
  final String refundStatus;

  CancelledOrder({
    required this.orderId,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.cancelledDate,
    required this.cancelledTime,
    required this.cancelReason,
    required this.refundStatus,
  });
}

// Enum untuk status aktivitas
enum ActivityStatus {
  completed,
  inProgress,
  pending,
}