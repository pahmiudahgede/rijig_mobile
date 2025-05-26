import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:el_tooltip/el_tooltip.dart';

class DatavisualizedScreen extends StatefulWidget {
  const DatavisualizedScreen({super.key});

  @override
  State<DatavisualizedScreen> createState() => _DatavisualizedScreenState();
}

class _DatavisualizedScreenState extends State<DatavisualizedScreen> {
  final List<double> dataSampahTerjual = [
    15.5,
    23.2,
    18.7,
    31.4,
    28.9,
    42.1,
    35.8,
  ];
  final List<String> namaHari = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  int? selectedIndex;
  final List<ElTooltipController> tooltipControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize tooltip controllers
    for (int i = 0; i < dataSampahTerjual.length; i++) {
      tooltipControllers.add(ElTooltipController());
    }
  }

  @override
  void dispose() {
    _hideAllTooltips();
    for (var controller in tooltipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Simple method to hide all tooltips
  void _hideAllTooltips() {
    for (var controller in tooltipControllers) {
      try {
        controller.hide();
      } catch (e) {
        // Ignore errors - controller might already be disposed
      }
    }
  }

  // Main selection handler - used by both bar clicks and day name clicks
  void _handleSelection(int index) {
    // If same item is selected, deselect it
    if (selectedIndex == index) {
      _clearSelection();
      return;
    }

    // Hide all tooltips first
    _hideAllTooltips();
    
    // Update selection
    setState(() {
      selectedIndex = index;
    });

    // Show tooltip after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && selectedIndex == index) {
        tooltipControllers[index].show();
      }
    });
  }

  // Clear selection and hide tooltips
  void _clearSelection() {
    _hideAllTooltips();
    setState(() {
      selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "Performa"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary card
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Chart section
            _buildChartSection(),
            const SizedBox(height: 12),

            // Day labels (clickable)
            _buildDayLabels(),
            const SizedBox(height: 16),

            // Selected item info card
            if (selectedIndex != null) _buildSelectedItemCard(),

            // Statistics cards
            _buildStatisticsCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.recycling, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sampah Terjual Minggu Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              Text(
                'Total: ${dataSampahTerjual.reduce((a, b) => a + b).toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafik Penjualan Sampah (kg)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Chart
              Chart<void>(
                state: ChartState<void>(
                  behaviour: ChartBehaviour(
                    onItemClicked: (item) {
                      final clickedIndex = dataSampahTerjual.indexWhere(
                        (data) => data == item.item.value,
                      );
                      if (clickedIndex != -1) {
                        _handleSelection(clickedIndex);
                      }
                    },
                  ),
                  data: ChartData.fromList(
                    dataSampahTerjual
                        .asMap()
                        .entries
                        .map((entry) => ChartItem<void>(entry.value))
                        .toList(),
                  ),
                  itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    barItemBuilder: (itemBuilderData) {
                      final isSelected = selectedIndex == itemBuilderData.itemIndex;
                      return BarItem(
                        color: isSelected ? Colors.orange.shade600 : primaryColor,
                      );
                    },
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      showVerticalGrid: false,
                      showHorizontalGrid: true,
                      horizontalAxisStep: 10,
                      gridColor: Colors.grey.shade300,
                    ),
                  ],
                  foregroundDecorations: [
                    SparkLineDecoration(
                      lineColor: Colors.orange.shade400,
                      lineWidth: 2,
                    ),
                  ],
                ),
                height: 250,
              ),
              // Tooltips overlay
              ..._buildTooltipOverlays(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTooltipOverlays() {
    return dataSampahTerjual.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      final chartWidth = MediaQuery.of(context).size.width - 64;
      final barWidth = chartWidth / dataSampahTerjual.length;

      return Positioned(
        left: (index * barWidth) + (barWidth / 2) - 20,
        top: 50,
        bottom: 50,
        width: 40,
        child: ElTooltip(
          controller: tooltipControllers[index],
          position: ElTooltipPosition.topCenter,
          color: Colors.black87,
          showArrow: true,
          showModal: false,
          showChildAboveOverlay: false,
          content: _buildTooltipContent(index, value),
          child: Container(width: 40, color: Colors.transparent),
        ),
      );
    }).toList();
  }

  Widget _buildTooltipContent(int index, double value) {
    return GestureDetector(
      onTap: () {
        tooltipControllers[index].hide();
        _showDetailDialog(index);
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              namaHari[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(1)} kg',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '👆 Tap untuk detail',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayLabels() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: namaHari.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = selectedIndex == index;
          
          return GestureDetector(
            onTap: () => _handleSelection(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.orange.shade700 : Colors.grey.shade700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedItemCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Terpilih: ${namaHari[selectedIndex!]}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Sampah terjual: ${dataSampahTerjual[selectedIndex!].toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: _clearSelection,
            child: Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          // Detail button
          GestureDetector(
            onTap: () => _navigateToDetailPage(selectedIndex!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Rata-rata',
                '${(dataSampahTerjual.reduce((a, b) => a + b) / dataSampahTerjual.length).toStringAsFixed(1)} kg',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Tertinggi',
                '${dataSampahTerjual.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)} kg',
                Icons.star,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Terendah',
                '${dataSampahTerjual.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)} kg',
                Icons.trending_down,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Hari Aktif',
                '${dataSampahTerjual.where((data) => data > 0).length} hari',
                Icons.calendar_today,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: primaryColor),
            const SizedBox(width: 8),
            Text('Detail ${namaHari[index]}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogInfoRow('Hari:', namaHari[index]),
            const SizedBox(height: 8),
            _buildDialogInfoRow(
              'Jumlah:',
              '${dataSampahTerjual[index].toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 8),
            _buildDialogInfoRow(
              'Persentase:',
              '${((dataSampahTerjual[index] / dataSampahTerjual.reduce((a, b) => a + b)) * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            _buildDialogInfoRow(
              'Ranking:',
              '#${_getRanking(index)} dari ${dataSampahTerjual.length} hari',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDetailPage(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Lihat Detail'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  int _getRanking(int index) {
    final sortedData = dataSampahTerjual
        .asMap()
        .entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedData.indexWhere((entry) => entry.key == index) + 1;
  }

  void _navigateToDetailPage(int index) {
    _hideAllTooltips();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHariScreen(
          hari: namaHari[index],
          jumlahSampah: dataSampahTerjual[index],
          index: index,
          allData: dataSampahTerjual,
          allDays: namaHari,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _clearSelection();
      }
    });
  }
}

class DetailHariScreen extends StatelessWidget {
  final String hari;
  final double jumlahSampah;
  final int index;
  final List<double> allData;
  final List<String> allDays;

  const DetailHariScreen({
    super.key,
    required this.hari,
    required this.jumlahSampah,
    required this.index,
    required this.allData,
    required this.allDays,
  });

  @override
  Widget build(BuildContext context) {
    final totalSampah = allData.reduce((a, b) => a + b);
    final persentase = (jumlahSampah / totalSampah) * 100;
    final ranking = _getRanking();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail $hari'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [primaryColor.withValues(alpha: 0.1), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.recycling,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Penjualan Sampah',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              hari,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${jumlahSampah.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Persentase: ${persentase.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Ranking: #$ranking dari ${allData.length} hari',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getRanking() {
    final sortedData = allData
        .asMap()
        .entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedData.indexWhere((entry) => entry.key == index) + 1;
  }
}