import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  // List untuk menyimpan item yang dipilih
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
    setState(() {
      selectedItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item berhasil dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _incrementQuantity(int index) {
    setState(() {
      selectedItems[index]['quantity'] += 2.5;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (selectedItems[index]['quantity'] > 0) {
        selectedItems[index]['quantity'] = 
            (selectedItems[index]['quantity'] - 2.5).clamp(0.0, double.infinity);
      }
    });
  }

  void _showQuantityDialog(int index) {
    TextEditingController controller = TextEditingController(
      text: selectedItems[index]['quantity'].toString()
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
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                double? newQuantity = double.tryParse(controller.text);
                if (newQuantity != null && newQuantity >= 0) {
                  setState(() {
                    selectedItems[index]['quantity'] = newQuantity;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Masukkan angka yang valid')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  double get totalWeight {
    return selectedItems.fold(0.0, (sum, item) => sum + item['quantity']);
  }

  int get estimatedEarnings {
    return selectedItems.fold<int>(0, (sum, item) => 
        sum + ((item['price'] as int) * (item['quantity'] as double)).round().toInt());
  }

  int get applicationFee {
    return 550;
  }

  int get estimatedIncome {
    return estimatedEarnings - applicationFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Jenis Sampah
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha:0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
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
                              onPressed: () {
                                // Navigate back to selection screen
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Colors.blue, size: 16),
                                  SizedBox(width: 4),
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
                        ),
                        SizedBox(height: 16),
                        
                        // List Items dengan Slidable
                        ...selectedItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> item = entry.value;
                          
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Slidable(
                              key: ValueKey(item['name']),
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) => _removeItem(index),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
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
                                    // Icon
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: item['backgroundColor'],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        item['icon'],
                                        color: item['iconColor'],
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    
                                    // Item info
                                    Expanded(
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
                                          SizedBox(height: 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Rp ${item['price']}/kg',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // Delete icon placeholder (always there for consistent height)
                                          SizedBox(
                                            height: 16,
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Quantity controls
                                    Row(
                                      children: [
                                        // Decrease button
                                        GestureDetector(
                                          onTap: () => _decrementQuantity(index),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              color: Colors.grey.shade600,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        
                                        // Quantity display (clickable)
                                        GestureDetector(
                                          onTap: () => _showQuantityDialog(index),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Text(
                                              '${item['quantity'].toString().replaceAll('.0', '')} kg',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        
                                        // Increase button
                                        GestureDetector(
                                          onTap: () => _incrementQuantity(index),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        
                        SizedBox(height: 16),
                        
                        // Total Weight
                        Container(
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
                                child: Icon(
                                  Icons.scale,
                                  color: Colors.grey.shade700,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
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
                                '${totalWeight.toString().replaceAll('.0', '')} kg',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Perkiraan Pendapatan
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha:0.1),
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
                              child: Icon(
                                Icons.folder,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
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
                        SizedBox(height: 16),
                        
                        // Estimasi pembayaran
                        _buildIncomeRow(
                          'Estimasi pembayaran',
                          estimatedEarnings,
                          Colors.orange,
                        ),
                        SizedBox(height: 8),
                        
                        // Biaya jasa aplikasi
                        _buildIncomeRow(
                          'Biaya jasa aplikasi',
                          applicationFee,
                          Colors.orange,
                          showInfo: true,
                        ),
                        SizedBox(height: 8),
                        
                        // Estimasi pendapatan
                        _buildIncomeRow(
                          'Estimasi pendapatan',
                          estimatedIncome,
                          Colors.orange,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Continue Button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedItems.isNotEmpty ? () {
                  // Handle continue action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lanjut ke proses selanjutnya'),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedItems.isNotEmpty ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lanjut',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeRow(String title, int amount, Color color, {bool showInfo = false, bool isBold = false}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.currency_exchange,
            color: Colors.white,
            size: 12,
          ),
        ),
        SizedBox(width: 8),
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
                SizedBox(width: 4),
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
        Text(
          amount.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}