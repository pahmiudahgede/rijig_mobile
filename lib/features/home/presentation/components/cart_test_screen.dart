import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  List<Map<String, dynamic>> selectedItems = [
    {
      'name': 'Plastik',
      'price': 1000,
      'quantity': 1.0,
      'icon': Icons.local_drink,
      'backgroundColor': Colors.blue.shade100,
      'iconColor': Colors.blue,
    },
    {
      'name': 'Kertas Campur',
      'price': 700,
      'quantity': 2.5,
      'icon': Icons.description,
      'backgroundColor': Colors.orange.shade100,
      'iconColor': Colors.orange,
    },
  ];

  void _removeItem(int index) {
    if (index < 0 || index >= selectedItems.length) return;

    final removedItem = selectedItems[index];
    setState(() {
      selectedItems.removeAt(index);
    });

    _showSnackbar('${removedItem['name']} berhasil dihapus');
  }

  void _clearAllItems() {
    if (selectedItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Semua Item'),
          content: Text(
            'Apakah Anda yakin ingin menghapus semua item dari daftar?',
          ),
          actions: [
            TextButton(
              onPressed: () => router.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedItems.clear();
                });
                router.pop(context);
                _showSnackbar('Semua item berhasil dihapus');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                foregroundColor: whiteColor,
              ),
              child: Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  void _incrementQuantity(int index) {
    if (index < 0 || index >= selectedItems.length) return;

    setState(() {
      selectedItems[index]['quantity'] += 0.5;
    });
  }

  void _decrementQuantity(int index) {
    if (index < 0 || index >= selectedItems.length) return;

    setState(() {
      final currentQuantity = selectedItems[index]['quantity'] as double;
      if (currentQuantity > 0.5) {
        selectedItems[index]['quantity'] = (currentQuantity - 0.5).clamp(
          0.0,
          double.infinity,
        );
      }
    });
  }

  void _showQuantityDialog(int index) {
    if (index < 0 || index >= selectedItems.length) return;

    final TextEditingController controller = TextEditingController(
      text: selectedItems[index]['quantity'].toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Jumlah ${selectedItems[index]['name']}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Jumlah (kg)',
              border: OutlineInputBorder(),
              suffixText: 'kg',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => router.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newQuantity = double.tryParse(controller.text);
                if (newQuantity != null && newQuantity > 0) {
                  setState(() {
                    selectedItems[index]['quantity'] = newQuantity;
                  });
                  router.pop(context);
                } else {
                  _showSnackbar('Masukkan angka yang valid (lebih dari 0)');
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  double get totalWeight {
    return selectedItems.fold(
      0.0,
      (sum, item) => sum + (item['quantity'] as double),
    );
  }

  int get estimatedEarnings {
    return selectedItems.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['price'] as int) * (item['quantity'] as double)).round(),
    );
  }

  int get applicationFee => 550;

  int get estimatedIncome => estimatedEarnings - applicationFee;

  bool get hasItems => selectedItems.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => router.pop(context),
        ),
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (hasItems)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllItems();
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: redColor, size: 20),
                          Gap(8),
                          Text(
                            'Hapus Semua',
                            style: TextStyle(color: redColor),
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
          Expanded(
            child:
                hasItems
                    ? SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildItemsSection(),
                          Gap(20),
                          _buildEarningsSection(),
                        ],
                      ),
                    )
                    : _buildEmptyState(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          Gap(16),
          Text(
            'Belum ada item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Gap(8),
          Text(
            'Tambahkan item sampah untuk melanjutkan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          Gap(24),
          ElevatedButton.icon(
            onPressed: () => router.pop(context),
            icon: Icon(Icons.add),
            label: Text('Tambah Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: whiteColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(),
          Gap(16),
          ...selectedItems.asMap().entries.map(
            (entry) => _buildItemCard(entry.key, entry.value),
          ),
          Gap(16),
          _buildTotalWeight(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_outline, color: Colors.orange, size: 20),
        ),
        Gap(12),
        Text(
          'Jenis Sampah',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: () => router.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.blue, size: 16),
              Gap(4),
              Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(int index, Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey('${item['name']}_$index'),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _removeItem(index),
              backgroundColor: redColor,
              foregroundColor: whiteColor,
              icon: Icons.delete,
              label: 'Hapus',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _buildItemIcon(item),
              Gap(12),
              _buildItemInfo(item),
              _buildQuantityControls(index, item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemIcon(Map<String, dynamic> item) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: item['backgroundColor'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(item['icon'], color: item['iconColor'], size: 20),
    );
  }

  Widget _buildItemInfo(Map<String, dynamic> item) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Gap(4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Rp ${item['price']}/kg',
              style: TextStyle(
                color: whiteColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(int index, Map<String, dynamic> item) {
    return Row(
      children: [
        _buildQuantityButton(
          icon: Icons.remove,
          onTap: () => _decrementQuantity(index),
          backgroundColor: whiteColor,
          iconColor: Colors.grey.shade600,
        ),
        Gap(8),
        GestureDetector(
          onTap: () => _showQuantityDialog(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '${_formatQuantity(item['quantity'])} kg',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Gap(8),
        _buildQuantityButton(
          icon: Icons.add,
          onTap: () => _incrementQuantity(index),
          backgroundColor: Colors.blue,
          iconColor: whiteColor,
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border:
              backgroundColor == whiteColor
                  ? Border.all(color: Colors.grey.shade300)
                  : null,
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
    );
  }

  Widget _buildTotalWeight() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.scale, color: Colors.grey.shade700, size: 16),
          ),
          Gap(12),
          Text(
            'Berat total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Spacer(),
          Text(
            '${_formatQuantity(totalWeight)} kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.folder, color: Colors.orange, size: 20),
              ),
              Gap(12),
              Text(
                'Perkiraan Pendapatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Gap(16),
          _buildIncomeRow(
            'Estimasi pembayaran',
            estimatedEarnings,
            Colors.orange,
          ),
          Gap(8),
          _buildIncomeRow(
            'Biaya jasa aplikasi',
            applicationFee,
            Colors.orange,
            showInfo: true,
          ),
          Gap(8),
          _buildIncomeRow(
            'Estimasi pendapatan',
            estimatedIncome,
            Colors.orange,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeRow(
    String title,
    int amount,
    Color color, {
    bool showInfo = false,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.currency_exchange, color: whiteColor, size: 12),
        ),
        Gap(8),
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              if (showInfo) ...[
                Gap(4),
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
              ],
            ],
          ),
        ),
        Text(
          'Rp ${_formatCurrency(amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              hasItems
                  ? () {
                    _showSnackbar('Lanjut ke proses selanjutnya');
                    // Handle continue action
                  }
                  : () => router.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasItems ? Colors.blue : Colors.grey.shade400,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            hasItems ? 'Lanjut' : 'Tambah Item',
            style: TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double quantity) {
    return quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toString();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
