import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'dart:math';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class Collector {
  final String name;
  final String address;
  final double rating;

  Collector({required this.name, required this.address, required this.rating});
}

class SelectCollectorScreen extends StatefulWidget {
  const SelectCollectorScreen({super.key});

  @override
  State<SelectCollectorScreen> createState() => _SelectCollectorScreenState();
}

class _SelectCollectorScreenState extends State<SelectCollectorScreen> {
  final List<Collector> collectors = List.generate(6, (index) {
    final names = [
      "Dimas Aditya",
      "Siti Nurhaliza",
      "Rizky Hidayat",
      "Indah Lestari",
      "Ahmad Fauzi",
      "Mega Putri",
    ];
    final addresses = [
      "Jl. Merdeka No. ${index + 1}, Jakarta",
      "Jl. Kebangsaan No. ${index + 2}, Bandung",
      "Jl. Kartini No. ${index + 3}, Surabaya",
      "Jl. Pancasila No. ${index + 4}, Yogyakarta",
      "Jl. Garuda No. ${index + 5}, Semarang",
      "Jl. Bhayangkara No. ${index + 6}, Medan",
    ];
    final random = Random();
    return Collector(
      name: names[index % names.length],
      address: addresses[index % addresses.length],
      rating: (random.nextDouble() * 2) + 3,
    );
  });

  void _showCollectorDialog(Collector collector) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: greyAbsolutColor,
                      child: Icon(Icons.person, color: whiteColor, size: 30),
                    ),
                    Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(collector.name, style: Tulisan.subheading()),
                          Gap(4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              Gap(4),
                              Text(
                                collector.rating.toStringAsFixed(1),
                                style: Tulisan.body(fontsize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(16),
                Text("Alamat:", style: Tulisan.body(fontsize: 13)),
                Gap(6),
                Text(collector.address, style: Tulisan.body(fontsize: 13)),
                Gap(24),
                CardButtonOne(
                  textButton: "Pilih",
                  fontSized: 14,
                  colorText: whiteColor,
                  color: primaryColor,
                  borderRadius: 8,
                  horizontal: double.infinity,
                  vertical: 45,
                  onTap: () {
                    router.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Data berhasil disimpan'),
                        margin: const EdgeInsets.only(
                          // bottom: 90,
                          left: 16,
                          right: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  usingRow: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomAppBar(judul: "Pilih Pengepul"),
      body: SafeArea(
        child: Padding(
          padding: PaddingCustom().paddingHorizontalVertical(20, 10),
          child: ListView.separated(
            itemCount: collectors.length,
            separatorBuilder: (_, __) => GapCustom().gapValue(10, true),
            itemBuilder: (context, index) {
              final collector = collectors[index];
              return GestureDetector(
                onTap: () => _showCollectorDialog(collector),
                child: Card(
                  shadowColor: Colors.transparent,
                  color: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(width: 1, color: greyColor),
                  ),
                  child: Padding(
                    padding: PaddingCustom().paddingAll(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: greyAbsolutColor,
                          child: Icon(
                            Icons.person,
                            color: whiteColor,
                            size: 28,
                          ),
                        ),
                        GapCustom().gapValue(16, false),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                collector.name,
                                style: Tulisan.subheading(fontsize: 16),
                              ),
                              GapCustom().gapValue(5, true),
                              Text(
                                collector.address,
                                style: TextStyle(
                                  color: greyAbsolutColor,
                                  fontSize: 14,
                                ),
                              ),
                              GapCustom().gapValue(5, true),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  GapCustom().gapValue(5, false),
                                  Text(
                                    collector.rating.toStringAsFixed(1),
                                    style: Tulisan.customText(fontsize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
