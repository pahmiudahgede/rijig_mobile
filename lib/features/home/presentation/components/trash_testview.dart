import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class TestRequestPickScreen extends StatefulWidget {
  const TestRequestPickScreen({super.key});

  @override
  State<TestRequestPickScreen> createState() => _TestRequestPickScreenState();
}

class _TestRequestPickScreenState extends State<TestRequestPickScreen> {
  // Map untuk menyimpan quantity setiap item
  Map<String, double> quantities = {
    'Plastik': 1.0,
    'Kertas Campur': 1.0,
    'Kaca': 0.0,
    'Minyak Jelantah': 0.0,
    'Kaleng Alumunium': 0.0,
  };

  // Map untuk menyimpan harga per kg
  Map<String, int> prices = {
    'Plastik': 1000,
    'Kertas Campur': 700,
    'Kaca': 300,
    'Minyak Jelantah': 2500,
    'Kaleng Alumunium': 3500,
  };

  // Map untuk menyimpan icon data
  Map<String, IconData> icons = {
    'Plastik': Icons.local_drink,
    'Kertas Campur': Icons.description,
    'Kaca': Icons.wine_bar,
    'Minyak Jelantah': Icons.opacity,
    'Kaleng Alumunium': Icons.recycling,
  };

  // Map untuk menyimpan warna background
  Map<String, Color> backgroundColors = {
    'Plastik': Colors.blue.shade100,
    'Kertas Campur': Colors.orange.shade100,
    'Kaca': Colors.red.shade100,
    'Minyak Jelantah': Colors.orange.shade200,
    'Kaleng Alumunium': Colors.green.shade100,
  };

  // Map untuk menyimpan warna icon
  Map<String, Color> iconColors = {
    'Plastik': Colors.blue,
    'Kertas Campur': Colors.orange,
    'Kaca': Colors.red,
    'Minyak Jelantah': Colors.orange.shade700,
    'Kaleng Alumunium': Colors.green,
  };

  void _resetQuantity(String itemName) {
    setState(() {
      quantities[itemName] = 0.0;
    });
  }

  void _incrementQuantity(String itemName) {
    setState(() {
      quantities[itemName] = (quantities[itemName]! + 2.5);
    });
  }

  void _decrementQuantity(String itemName) {
    setState(() {
      if (quantities[itemName]! > 0) {
        quantities[itemName] = (quantities[itemName]! - 2.5).clamp(
          0.0,
          double.infinity,
        );
      }
    });
  }

  void _showQuantityDialog(String itemName) {
    TextEditingController controller = TextEditingController(
      text: quantities[itemName]!.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Jumlah $itemName'),
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
                    quantities[itemName] = newQuantity;
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
    return quantities.values.fold(0.0, (sum, quantity) => sum + quantity);
  }

  int get totalPrice {
    int total = 0;
    quantities.forEach((item, quantity) {
      total += (prices[item]! * quantity).round();
    });
    return total;
  }

  int get totalItems {
    return quantities.values.where((quantity) => quantity > 0).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Purbalingga',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text('Ganti', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: whiteColor,
            child: Text(
              'Pilih Sampah',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          // List Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: quantities.keys.length,
              itemBuilder: (context, index) {
                String itemName = quantities.keys.elementAt(index);
                double quantity = quantities[itemName]!;
                int price = prices[itemName]!;

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
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
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColors[itemName],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          icons[itemName],
                          color: iconColors[itemName],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),

                      // Item info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              itemName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Rp $price/kg',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Show delete icon when quantity > 0 (below price)
                            SizedBox(height: 4),
                            SizedBox(
                              height: 24, // Fixed height untuk consistency
                              child:
                                  quantity > 0
                                      ? GestureDetector(
                                        onTap: () => _resetQuantity(itemName),
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ),
                                      )
                                      : SizedBox(), // Empty space when no quantity
                            ),
                          ],
                        ),
                      ),

                      // Quantity controls or Add button
                      quantity > 0
                          ? Row(
                            children: [
                              // Decrease button
                              GestureDetector(
                                onTap: () => _decrementQuantity(itemName),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),

                              // Quantity display (clickable)
                              GestureDetector(
                                onTap: () => _showQuantityDialog(itemName),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${quantity.toString().replaceAll('.0', '')} kg',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),

                              // Increase button
                              GestureDetector(
                                onTap: () => _incrementQuantity(itemName),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              // Add button when quantity is 0
                              GestureDetector(
                                onTap: () => _incrementQuantity(itemName),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom summary
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalItems jenis    ${totalWeight.toString().replaceAll('.0', '')} kg',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Est. ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
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
                              'Rp ${totalPrice.toString()}',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Minimum total berat 3kg',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      totalWeight >= 3
                          ? () {
                            // Handle continue action
                            router.push('/ordersumary');
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text('Lanjut ke proses selanjutnya'),
                            //   ),
                            // );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        totalWeight >= 3 ? Colors.blue : Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lanjut',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
