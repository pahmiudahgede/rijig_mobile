import 'package:flutter/material.dart';

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCard(
                'Pendapatan',
                'Rp 35.000',
                Icons.account_balance_wallet,
              ),
              _buildCard('Sampah', '10 Kg', Icons.delete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon on the left
              Icon(icon, color: Colors.blue, size: 40),
              SizedBox(width: 10),
              // Column for title and value on the right
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
