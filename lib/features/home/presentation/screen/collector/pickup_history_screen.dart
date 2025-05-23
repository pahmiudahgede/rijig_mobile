import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/appbar.dart';

class PickupHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData = [
    {"label": "Mon", "amount": 200000, "orders": 10},
    {"label": "Tue", "amount": 0, "orders": 0},
    {"label": "Wed", "amount": 100000, "orders": 7},
    {"label": "Thu", "amount": 0, "orders": 0},
    {"label": "Fri", "amount": 140000, "orders": 13},
    {"label": "Sat", "amount": 50000, "orders": 5},
    {"label": "Sun", "amount": 210000, "orders": 15},
  ];

  PickupHistoryScreen({super.key});

  Widget _dateRangeTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : greyColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = weeklyData.fold<int>(
      0,
      (sum, d) => sum + (d['amount'] as int),
    );
    final totalOrders = weeklyData.fold<int>(
      0,
      (sum, d) => sum + (d['orders'] as int),
    );

    return Scaffold(
      appBar: CustomAppBar(judul: "Riwayat Pickup"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Center(child: Text("Day", style: Tulisan.body())),
                ),
                Expanded(
                  child: Center(
                    child: Text("Week", style: Tulisan.body(color: redColor)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _dateRangeTab("Oct\n5 - 11", false),
                _dateRangeTab("Oct\n12 - 18", false),
                _dateRangeTab("Oct\n19 - 25", false),
                _dateRangeTab("Oct - Nov\n26 - 1", true),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text("Total Income", style: Tulisan.body(fontsize: 14)),
          ),
          const SizedBox(height: 8),
          Center(child: Text("Rp$totalIncome", style: Tulisan.heading())),
          Center(
            child: Text(
              "$totalOrders Orders Completed",
              style: Tulisan.body(fontsize: 12),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Income Trend", style: Tulisan.subheading()),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 250000,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final label = weeklyData[value.toInt()]["label"];
                          return Text(
                            label,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      weeklyData
                          .asMap()
                          .map(
                            (index, data) => MapEntry(
                              index,
                              BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: data["amount"].toDouble(),
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .values
                          .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
