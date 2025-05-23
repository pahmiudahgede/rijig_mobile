import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class CollectorRequestList extends StatelessWidget {
  final List<Map<String, dynamic>> allRequests = List.generate(
    5,
    (index) => {
      "name": "Nama ${index + 1}",
      "phone": "62${81300000000 + index}",
      "request_trash": [
        {"trash_name": "Botol Plastik", "amoun_weight": 12 + index},
        {"trash_name": "Kardus", "amoun_weight": 15 + index},
      ],
      "address": "Desa Banyuwangi ${index + 1}",
      "distance_from_you": 12.0 - index,
      "requestedAt": "${9 + index}:${(index + 1) * 5}".padLeft(2, '0'),
    },
  );

  final Map<String, dynamic> myRequest = {
    "name": "Andi Wijaya",
    "phone": "6281399991234",
    "request_trash": [
      {"trash_name": "Kertas", "amoun_weight": 8},
    ],
    "address": "Desa Sumberagung",
    "distance_from_you": 13.7,
    "requestedAt": "10:15",
  };

  CollectorRequestList({super.key});

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _showRequestDetailDialog(context, data),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'], style: Tulisan.subheading()),
            const SizedBox(height: 4),
            Text("Telp: ${data['phone']}", style: Tulisan.body(fontsize: 12)),
            const SizedBox(height: 8),
            Text(
              "Alamat: ${data['address']}",
              style: Tulisan.body(fontsize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              "Jarak: ${data['distance_from_you'].toStringAsFixed(1)} km",
              style: Tulisan.body(fontsize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              "Waktu Permintaan: ${data['requestedAt']}",
              style: Tulisan.body(fontsize: 12),
            ),
            const SizedBox(height: 12),
            Text("Detail Sampah:", style: Tulisan.body(fontsize: 13)),
            const SizedBox(height: 4),
            ...List.generate((data['request_trash'] as List).length, (i) {
              final trash = data['request_trash'][i];
              return Text(
                "• ${trash['trash_name']} - ${trash['amoun_weight']} kg",
                style: Tulisan.body(fontsize: 12),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showRequestDetailDialog(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'], style: Tulisan.subheading()),
                const SizedBox(height: 6),
                Text(
                  "Telp: ${data['phone']}",
                  style: Tulisan.body(fontsize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  "Alamat: ${data['address']}",
                  style: Tulisan.body(fontsize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  "Jarak: ${data['distance_from_you'].toStringAsFixed(1)} km",
                  style: Tulisan.body(fontsize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  "Waktu Permintaan: ${data['requestedAt']}",
                  style: Tulisan.body(fontsize: 12),
                ),
                const SizedBox(height: 12),
                Text("Detail Sampah:", style: Tulisan.body(fontsize: 13)),
                const SizedBox(height: 6),
                ...List.generate((data['request_trash'] as List).length, (i) {
                  final trash = data['request_trash'][i];
                  return Text(
                    "• ${trash['trash_name']} - ${trash['amoun_weight']} kg",
                    style: Tulisan.body(fontsize: 12),
                  );
                }),
                const SizedBox(height: 20),
                CardButtonOne(
                  textButton: "Konfirmasi",
                  fontSized: 14,
                  colorText: whiteColor,
                  color: primaryColor,
                  borderRadius: 8,
                  horizontal: double.infinity,
                  vertical: 45,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pickup dikonfirmasi")),
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
    return TabBarView(
      children: [
        ListView.builder(
          itemCount: allRequests.length,
          itemBuilder:
              (context, index) =>
                  _buildRequestCard(context, allRequests[index]),
        ),
        ListView(children: [_buildRequestCard(context, myRequest)]),
      ],
    );
  }
}
