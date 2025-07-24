import 'package:flutter/material.dart';
import 'package:charts_painter/chart.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/appbar.dart';

class PickupHistoryScreen extends StatefulWidget {
  const PickupHistoryScreen({super.key});

  @override
  State<PickupHistoryScreen> createState() => _PickupHistoryScreenState();
}

class _PickupHistoryScreenState extends State<PickupHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  int _selectedDateRangeIndex = 3;
  int _selectedViewIndex = 1;
  int? selectedDayIndex;

  // Data yang lebih realistis untuk sampah
  final List<Map<String, dynamic>> _weeklyData = [
    {
      "label": "Mon",
      "totalAmount": 75000,
      "totalWeight": 15.5,
      "orders": 3,
      "wasteTypes": {
        "Plastik PET": {"weight": 8.2, "price": 4000, "amount": 32800},
        "Kertas": {"weight": 5.5, "price": 2500, "amount": 13750},
        "Logam": {"weight": 1.8, "price": 15000, "amount": 27000},
        "Kaca": {"weight": 0, "price": 1500, "amount": 0},
      },
    },
    {
      "label": "Tue",
      "totalAmount": 0,
      "totalWeight": 0,
      "orders": 0,
      "wasteTypes": {
        "Plastik PET": {"weight": 0, "price": 4000, "amount": 0},
        "Kertas": {"weight": 0, "price": 2500, "amount": 0},
        "Logam": {"weight": 0, "price": 15000, "amount": 0},
        "Kaca": {"weight": 0, "price": 1500, "amount": 0},
      },
    },
    {
      "label": "Wed",
      "totalAmount": 142500,
      "totalWeight": 22.8,
      "orders": 5,
      "wasteTypes": {
        "Plastik PET": {"weight": 12.5, "price": 4000, "amount": 50000},
        "Kertas": {"weight": 8.3, "price": 2500, "amount": 20750},
        "Logam": {"weight": 1.2, "price": 15000, "amount": 18000},
        "Kaca": {"weight": 0.8, "price": 1500, "amount": 1200},
      },
    },
    {
      "label": "Thu",
      "totalAmount": 0,
      "totalWeight": 0,
      "orders": 0,
      "wasteTypes": {
        "Plastik PET": {"weight": 0, "price": 4000, "amount": 0},
        "Kertas": {"weight": 0, "price": 2500, "amount": 0},
        "Logam": {"weight": 0, "price": 15000, "amount": 0},
        "Kaca": {"weight": 0, "price": 1500, "amount": 0},
      },
    },
    {
      "label": "Fri",
      "totalAmount": 196750,
      "totalWeight": 35.2,
      "orders": 7,
      "wasteTypes": {
        "Plastik PET": {"weight": 18.5, "price": 4000, "amount": 74000},
        "Kertas": {"weight": 12.7, "price": 2500, "amount": 31750},
        "Logam": {"weight": 2.8, "price": 15000, "amount": 42000},
        "Kaca": {"weight": 1.2, "price": 1500, "amount": 1800},
      },
    },
    {
      "label": "Sat",
      "totalAmount": 98500,
      "totalWeight": 18.6,
      "orders": 4,
      "wasteTypes": {
        "Plastik PET": {"weight": 9.8, "price": 4000, "amount": 39200},
        "Kertas": {"weight": 6.2, "price": 2500, "amount": 15500},
        "Logam": {"weight": 1.8, "price": 15000, "amount": 27000},
        "Kaca": {"weight": 0.8, "price": 1500, "amount": 1200},
      },
    },
    {
      "label": "Sun",
      "totalAmount": 168250,
      "totalWeight": 28.4,
      "orders": 6,
      "wasteTypes": {
        "Plastik PET": {"weight": 15.2, "price": 4000, "amount": 60800},
        "Kertas": {"weight": 9.8, "price": 2500, "amount": 24500},
        "Logam": {"weight": 2.4, "price": 15000, "amount": 36000},
        "Kaca": {"weight": 1.0, "price": 1500, "amount": 1500},
      },
    },
  ];

  final List<String> _dateRanges = [
    "Nov\n4 - 10",
    "Nov\n11 - 17",
    "Nov\n18 - 24",
    "Nov - Des\n25 - 1",
  ];

  final List<ElTooltipController> tooltipControllers = [];

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _chartAnimationController.forward();

    for (int i = 0; i < _weeklyData.length; i++) {
      tooltipControllers.add(ElTooltipController());
    }
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _hideAllTooltips();
    for (var controller in tooltipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _hideAllTooltips() {
    for (var controller in tooltipControllers) {
      try {
        controller.hide();
      } catch (e) {
        debugPrint("Kesalahan ${e.toString()}");
      }
    }
  }

  void _handleSelection(int index) {
    if (selectedDayIndex == index) {
      _clearSelection();
      return;
    }

    _hideAllTooltips();

    setState(() {
      selectedDayIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && selectedDayIndex == index) {
        tooltipControllers[index].show();
      }
    });
  }

  void _clearSelection() {
    _hideAllTooltips();
    setState(() {
      selectedDayIndex = null;
    });
  }

  int get _totalExpense =>
      _weeklyData.fold<int>(0, (sum, d) => sum + (d['totalAmount'] as int));

  double get _totalWeight => _weeklyData.fold<double>(
    0.0,
    (sum, d) => sum + (d['totalWeight'] as num).toDouble(),
  );

  int get _totalOrders =>
      _weeklyData.fold<int>(0, (sum, d) => sum + (d['orders'] as int));

  double get _maxAmount =>
      _weeklyData.isNotEmpty
          ? _weeklyData
              .map((e) => (e['totalAmount'] as num).toDouble())
              .reduce((a, b) => a > b ? a : b)
          : 0.0;

  List<double> get _chartAmounts =>
      _weeklyData.map((e) => (e['totalAmount'] as num).toDouble()).toList();

  String _formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  // Mendapatkan jenis sampah dengan berat terbanyak
  String get _topWasteType {
    Map<String, double> totalByType = {};
    for (var day in _weeklyData) {
      Map<String, dynamic> wasteTypes = day['wasteTypes'];
      wasteTypes.forEach((type, data) {
        totalByType[type] =
            (totalByType[type] ?? 0) + (data['weight'] as num).toDouble();
      });
    }

    if (totalByType.isEmpty) return "Tidak ada data";

    var topEntry = totalByType.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return "${topEntry.key} (${_formatWeight(topEntry.value)})";
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedViewIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _selectedViewIndex == 0
                          ? Colors.white
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow:
                      _selectedViewIndex == 0
                          ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    "Day",
                    style: Tulisan.customText(
                      color:
                          _selectedViewIndex == 0
                              ? primaryColor
                              : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedViewIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _selectedViewIndex == 1
                          ? Colors.white
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow:
                      _selectedViewIndex == 1
                          ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    "Week",
                    style: Tulisan.customText(
                      color:
                          _selectedViewIndex == 1
                              ? primaryColor
                              : Colors.grey[600],
                      fontWeight:
                          _selectedViewIndex == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeTab(String label, int index) {
    final isActive = index == _selectedDateRangeIndex;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDateRangeIndex = index);
        _chartAnimationController.reset();
        _chartAnimationController.forward();
        _clearSelection();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isActive
                      ? primaryColor.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
              blurRadius: isActive ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Purchase Cost Card
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.08),
                    Colors.blue.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Total Pembelian",
                        style: Tulisan.customText(
                          fontsize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatCurrency(_totalExpense),
                    style: Tulisan.heading(
                      fontsize: 24,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$_totalOrders Transaksi",
                      style: Tulisan.customText(
                        fontsize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Weight and Top Waste Cards
          Expanded(
            child: Column(
              children: [
                // Weight Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.scale_outlined,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Total Berat",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatWeight(_totalWeight),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Top Waste Type Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Terbanyak",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _topWasteType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Trend Pembelian Sampah",
                style: Tulisan.subheading(
                  color: Colors.grey[800],
                  fontsize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Mingguan",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildChartSection(),
          const SizedBox(height: 12),
          _buildDayLabels(),
          if (selectedDayIndex != null) ...[
            const SizedBox(height: 16),
            _buildSelectedItemCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 250,
          child: Stack(
            children: [
              Chart<void>(
                state: ChartState<void>(
                  behaviour: ChartBehaviour(
                    onItemClicked: (item) {
                      final clickedIndex = _chartAmounts.indexWhere(
                        (data) => data == item.item.value,
                      );
                      if (clickedIndex != -1) {
                        _handleSelection(clickedIndex);
                      }
                    },
                  ),
                  data: ChartData.fromList(
                    _chartAmounts
                        .map(
                          (amount) =>
                              ChartItem<void>(amount * _chartAnimation.value),
                        )
                        .toList(),
                  ),
                  itemOptions: BarItemOptions(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    barItemBuilder: (itemBuilderData) {
                      final isSelected =
                          selectedDayIndex == itemBuilderData.itemIndex;
                      return BarItem(
                        color:
                            isSelected
                                ? Colors.orange.shade600
                                : Colors.blue.shade600,
                      );
                    },
                  ),
                  backgroundDecorations: [
                    GridDecoration(
                      showVerticalGrid: false,
                      showHorizontalGrid: true,
                      horizontalAxisStep:
                          _maxAmount > 0 ? _maxAmount / 4 : 50000,
                      gridColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ],
                  foregroundDecorations: [
                    SparkLineDecoration(
                      lineColor: Colors.blue.shade600.withValues(alpha: 0.5),
                      lineWidth: 2,
                    ),
                  ],
                ),
                height: 200,
              ),
              ..._buildTooltipOverlays(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTooltipOverlays() {
    return _weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final chartWidth = MediaQuery.of(context).size.width - 72;
      final barWidth = chartWidth / _weeklyData.length;

      return Positioned(
        left: (index * barWidth) + (barWidth / 2) - 20,
        top: 20,
        bottom: 50,
        width: 40,
        child: ElTooltip(
          controller: tooltipControllers[index],
          position: ElTooltipPosition.topCenter,
          color: Colors.black87,
          showArrow: true,
          showModal: false,
          showChildAboveOverlay: false,
          content: _buildTooltipContent(index, data),
          child: Container(width: 40, color: Colors.transparent),
        ),
      );
    }).toList();
  }

  Widget _buildTooltipContent(int index, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        tooltipControllers[index].hide();
        _showDetailDialog(index);
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 140),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data['label'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(data['totalAmount'] as int),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${_formatWeight((data['totalWeight'] as num).toDouble())} • ${data['orders']} transaksi",
              style: const TextStyle(color: Colors.white70, fontSize: 10),
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
                style: TextStyle(color: Colors.white70, fontSize: 9),
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
        children:
            _weeklyData.asMap().entries.map((entry) {
              final index = entry.key;
              final isSelected = selectedDayIndex == index;

              return GestureDetector(
                onTap: () => _handleSelection(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.orange.shade100
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.value['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color:
                          isSelected
                              ? Colors.orange.shade700
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSelectedItemCard() {
    final data = _weeklyData[selectedDayIndex!];
    return Container(
      margin: const EdgeInsets.only(top: 8),
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
                  'Data Terpilih: ${data['label']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_formatCurrency(data['totalAmount'] as int)} • ${_formatWeight((data['totalWeight'] as num).toDouble())} • ${data['orders']} transaksi',
                  style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _clearSelection,
            child: Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.close, size: 16, color: Colors.orange.shade700),
            ),
          ),
          GestureDetector(
            onTap: () => _showDetailDialog(selectedDayIndex!),
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

  void _showDetailDialog(int index) {
    final data = _weeklyData[index];
    Map<String, dynamic> wasteTypes = data['wasteTypes'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text('Detail ${data['label']}'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDialogInfoRow('Hari:', data['label']),
                  const SizedBox(height: 8),
                  _buildDialogInfoRow(
                    'Total Biaya:',
                    _formatCurrency(data['totalAmount'] as int),
                  ),
                  const SizedBox(height: 8),
                  _buildDialogInfoRow(
                    'Total Berat:',
                    _formatWeight((data['totalWeight'] as num).toDouble()),
                  ),
                  const SizedBox(height: 8),
                  _buildDialogInfoRow(
                    'Jumlah Transaksi:',
                    '${data['orders']} transaksi',
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Breakdown per Jenis Sampah:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...wasteTypes.entries.map((entry) {
                    String wasteType = entry.key;
                    Map<String, dynamic> typeData = entry.value;
                    double weight = (typeData['weight'] as num).toDouble();
                    int price = typeData['price'] as int;
                    int amount = typeData['amount'] as int;

                    if (weight > 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
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
                              wasteType,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Berat: ${_formatWeight(weight)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  '${_formatCurrency(price)}/kg',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              'Subtotal: ${_formatCurrency(amount)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  if ((data['totalWeight'] as num).toDouble() > 0) ...[
                    const SizedBox(height: 8),
                    _buildDialogInfoRow(
                      'Rata-rata Harga:',
                      '${_formatCurrency(((data['totalAmount'] as int) / (data['totalWeight'] as num).toDouble()).round())}/kg',
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
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
          width: 120,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(judul: "Riwayat Pembelian Sampah"),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildViewToggle(),
          const SizedBox(height: 20),
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _dateRanges.length,
              itemBuilder:
                  (context, index) =>
                      _buildDateRangeTab(_dateRanges[index], index),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [_buildChart(), const SizedBox(height: 24)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
