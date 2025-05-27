import 'package:flutter/material.dart';

enum InfoStateType { dataNotFound, emptyData, comingSoon }

class InfoStateWidget extends StatelessWidget {
  final InfoStateType type;
  final String? imageAsset;
  final String? description;

  const InfoStateWidget({
    super.key,
    required this.type,
    this.imageAsset,
    this.description,
  });

  String _getDefaultDescription() {
    switch (type) {
      case InfoStateType.dataNotFound:
        return 'Data tidak ditemukan';
      case InfoStateType.emptyData:
        return 'Belum ada data yang tersedia';
      case InfoStateType.comingSoon:
        return 'Fitur ini segera hadir';
    }
  }

  String _getDefaultImageAsset() {
    switch (type) {
      case InfoStateType.dataNotFound:
        return 'assets/image/empty_data.png';
      case InfoStateType.emptyData:
        return 'assets/image/empty_data.png';
      case InfoStateType.comingSoon:
        return 'assets/image/empty_data.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imageAsset ?? _getDefaultImageAsset(),
              width: screenWidth * 0.5,
              height: screenHeight * 0.3,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              description ?? _getDefaultDescription(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
