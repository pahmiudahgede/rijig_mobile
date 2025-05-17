import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/counter_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double totalWeight = 1.0;
  double pricePerKg = 700;

  void _openEditAmountDialog(String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAmountDialog(
          initialAmount: totalWeight,
          itemName: itemName,
          pricePerKg: pricePerKg,
          onSave: (newAmount) {
            setState(() {
              totalWeight = newAmount;
            });
          },
        );
      },
    );
  }

  void _increment() {
    setState(() {
      totalWeight += 0.25;
    });
  }

  void _decrement() {
    if (totalWeight > 0.25) {
      setState(() {
        totalWeight -= 0.25;
      });
    }
  }

  String formatAmount(double value) {
    String formattedValue = value.toStringAsFixed(2);

    if (formattedValue.endsWith('.00')) {
      return formattedValue.split('.').first;
    }

    return formattedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Keranjang Sampah',
          style: Tulisan.subheading(color: blackNavyColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PaddingCustom().paddingHorizontal(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Penjemputan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Lokasi harus di Jember',
                        style: TextStyle(fontSize: 14),
                      ),

                      Gap(15),
                      CardButtonOne(
                        textButton: "Pilih Alamat",
                        fontSized: 16.sp,
                        color: primaryColor,
                        colorText: whiteColor,
                        borderRadius: 9,
                        horizontal: double.infinity,
                        vertical: 40,
                        onTap: () {
                          debugPrint("pilih alamat tapped");
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jenis Sampah',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.delete, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Kertas Campur'),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              _openEditAmountDialog('Kertas Campur');
                            },
                            child: Row(
                              children: [
                                Text("${formatAmount(totalWeight)} kg"),
                                Icon(Icons.edit, color: Colors.blue),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: _decrement,
                            icon: Icon(Icons.remove),
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            onPressed: _increment,
                            icon: Icon(Icons.add),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimasi Total Berat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${formatAmount(totalWeight)} kg",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Center(
                  child: CardButtonOne(
                    textButton: "Lanjutkan",
                    fontSized: 16.sp,
                    color: primaryColor,
                    colorText: whiteColor,
                    borderRadius: 9,
                    horizontal: double.infinity,
                    vertical: 60,
                    onTap: () {
                      debugPrint("lanjutkan tapped");
                    },
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
