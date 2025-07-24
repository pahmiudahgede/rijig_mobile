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
  // Data contoh untuk timeline pickup sampah
  final List<ActivityItem> processActivities = [
    ActivityItem(
      title: 'Request Diterima',
      description: 'Permintaan pickup sampah Anda telah diterima pengepul',
      time: '09:15',
      date: '15 Des 2024',
      status: ActivityStatus.completed,
      icon: Icons.check_circle,
    ),
    ActivityItem(
      title: 'Pengepul Menuju Lokasi',
      description: 'Pengepul sedang dalam perjalanan ke alamat Anda',
      time: '09:45',
      date: '15 Des 2024',
      status: ActivityStatus.inProgress,
      icon: Icons.directions_car,
    ),
    ActivityItem(
      title: 'Sampah Dipickup',
      description: 'Proses penimbangan dan pengambilan sampah',
      time: '',
      date: '',
      status: ActivityStatus.pending,
      icon: Icons.scale,
    ),
    ActivityItem(
      title: 'Pembayaran Diproses',
      description: 'Perhitungan dan transfer pembayaran ke rekening Anda',
      time: '',
      date: '',
      status: ActivityStatus.pending,
      icon: Icons.payment,
    ),
    ActivityItem(
      title: 'Selesai',
      description: 'Pickup sampah berhasil diselesaikan',
      time: '',
      date: '',
      status: ActivityStatus.pending,
      icon: Icons.task_alt,
    ),
  ];

  // Data contoh untuk pickup selesai
  final List<CompletedPickup> completedPickups = [
    CompletedPickup(
      pickupId: '#WP001',
      wasteTypes: 'Plastik PET, Kertas, Logam',
      totalWeight: 12.5,
      totalAmount: 'Rp 45.000',
      completedDate: '12 Des 2024',
      completedTime: '14:30',
      rating: 5,
      collectorNote: 'Sampah sudah dipilah dengan baik, terima kasih!',
      details: [
        WasteDetail(
          type: 'Plastik PET',
          weight: 6.5,
          pricePerKg: 4000,
          amount: 26000,
        ),
        WasteDetail(
          type: 'Kertas',
          weight: 4.0,
          pricePerKg: 2500,
          amount: 10000,
        ),
        WasteDetail(
          type: 'Logam',
          weight: 2.0,
          pricePerKg: 15000,
          amount: 30000,
        ),
      ],
    ),
    CompletedPickup(
      pickupId: '#WP002',
      wasteTypes: 'Plastik, Kaca',
      totalWeight: 8.2,
      totalAmount: 'Rp 28.500',
      completedDate: '10 Des 2024',
      completedTime: '16:15',
      rating: 4,
      collectorNote: 'Pickup berjalan lancar',
      details: [
        WasteDetail(
          type: 'Plastik PET',
          weight: 5.5,
          pricePerKg: 4000,
          amount: 22000,
        ),
        WasteDetail(type: 'Kaca', weight: 2.7, pricePerKg: 1500, amount: 4050),
      ],
    ),
    CompletedPickup(
      pickupId: '#WP003',
      wasteTypes: 'Kertas, Kardus',
      totalWeight: 15.8,
      totalAmount: 'Rp 39.500',
      completedDate: '8 Des 2024',
      completedTime: '11:20',
      rating: 5,
      collectorNote: '',
      details: [
        WasteDetail(
          type: 'Kertas',
          weight: 9.3,
          pricePerKg: 2500,
          amount: 23250,
        ),
        WasteDetail(
          type: 'Kardus',
          weight: 6.5,
          pricePerKg: 2500,
          amount: 16250,
        ),
      ],
    ),
  ];

  // Data contoh untuk pickup dibatalkan
  final List<CancelledPickup> cancelledPickups = [
    CancelledPickup(
      pickupId: '#WP004',
      wasteTypes: 'Plastik, Kertas',
      estimatedWeight: 5.0,
      estimatedAmount: 'Rp 18.000',
      cancelledDate: '7 Des 2024',
      cancelledTime: '13:20',
      cancelReason: 'Pengepul tidak dapat datang karena cuaca buruk',
      cancelledBy: 'Pengepul',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: Text('Aktivitas Pickup', style: Tulisan.subheading()),
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
                    TabItem(title: 'Proses', count: 1),
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
      child:
          completedPickups.isEmpty
              ? Center(child: InfoStateWidget(type: InfoStateType.emptyData))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: completedPickups.length,
                itemBuilder: (context, index) {
                  final pickup = completedPickups[index];
                  return _buildCompletedPickupCard(pickup);
                },
              ),
    );
  }

  Widget _buildCompletedPickupCard(CompletedPickup pickup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                pickup.pickupId,
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

          // Konten pickup
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
                  Icons.recycling,
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
                      pickup.wasteTypes,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total berat: ${pickup.totalWeight} kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pickup pada ${pickup.completedDate} • ${pickup.completedTime}',
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
                    pickup.totalAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRatingStars(pickup.rating),
                ],
              ),
            ],
          ),

          // Breakdown jenis sampah
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Sampah:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ...pickup.details.map(
                  (detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${detail.type} (${detail.weight} kg)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Rp ${detail.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Catatan pengepul jika ada
          if (pickup.collectorNote.isNotEmpty) ...[
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
                        'Catatan Pengepul:',
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
                    pickup.collectorNote,
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
                  icon: Icon(Icons.visibility, size: 16, color: primaryColor),
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
                    // Action untuk request pickup lagi
                  },
                  icon: const Icon(
                    Icons.add_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Request Lagi',
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
      child:
          cancelledPickups.isEmpty
              ? Center(child: InfoStateWidget(type: InfoStateType.emptyData))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cancelledPickups.length,
                itemBuilder: (context, index) {
                  final pickup = cancelledPickups[index];
                  return _buildCancelledPickupCard(pickup);
                },
              ),
    );
  }

  Widget _buildCancelledPickupCard(CancelledPickup pickup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                pickup.pickupId,
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
                    Icon(Icons.cancel, size: 14, color: Colors.red.shade700),
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

          // Konten pickup
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
                  Icons.recycling_outlined,
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
                      pickup.wasteTypes,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimasi berat: ${pickup.estimatedWeight} kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dibatalkan pada ${pickup.cancelledDate} • ${pickup.cancelledTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                pickup.estimatedAmount,
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
                  pickup.cancelReason,
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Dibatalkan oleh: ${pickup.cancelledBy}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
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
                // Action untuk request pickup lagi
              },
              icon: Icon(Icons.add_circle, size: 16, color: primaryColor),
              label: Text(
                'Request Pickup Lagi',
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.recycling,
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
                              'Pickup Request #WP005',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Estimasi: 8 kg • Rp 30.000',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Pickup Sampah',
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
        indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
        connectorTheme: const ConnectorThemeData(thickness: 2.0),
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
            color:
                index < processActivities.length - 1 &&
                        processActivities[index].status ==
                            ActivityStatus.completed
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
        indicatorChild = Icon(Icons.check, color: Colors.white, size: 12);
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

    return DotIndicator(size: 20, color: indicatorColor, child: indicatorChild);
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
                color:
                    item.status == ActivityStatus.completed
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
                    color:
                        item.status == ActivityStatus.pending
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
                    color:
                        item.status == ActivityStatus.pending
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

// Model untuk item aktivitas pickup sampah
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

// Model untuk detail jenis sampah
class WasteDetail {
  final String type;
  final double weight;
  final int pricePerKg;
  final int amount;

  WasteDetail({
    required this.type,
    required this.weight,
    required this.pricePerKg,
    required this.amount,
  });
}

// Model untuk pickup selesai
class CompletedPickup {
  final String pickupId;
  final String wasteTypes;
  final double totalWeight;
  final String totalAmount;
  final String completedDate;
  final String completedTime;
  final int rating;
  final String collectorNote;
  final List<WasteDetail> details;

  CompletedPickup({
    required this.pickupId,
    required this.wasteTypes,
    required this.totalWeight,
    required this.totalAmount,
    required this.completedDate,
    required this.completedTime,
    required this.rating,
    required this.collectorNote,
    required this.details,
  });
}

// Model untuk pickup dibatalkan
class CancelledPickup {
  final String pickupId;
  final String wasteTypes;
  final double estimatedWeight;
  final String estimatedAmount;
  final String cancelledDate;
  final String cancelledTime;
  final String cancelReason;
  final String cancelledBy;

  CancelledPickup({
    required this.pickupId,
    required this.wasteTypes,
    required this.estimatedWeight,
    required this.estimatedAmount,
    required this.cancelledDate,
    required this.cancelledTime,
    required this.cancelReason,
    required this.cancelledBy,
  });
}

// Enum untuk status aktivitas
enum ActivityStatus { completed, inProgress, pending }
