// lib/features/home/presentation/widgets/request_card.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/home/model/c_request_list_dummymodel.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onTap;

  const RequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [_buildHeader(), _buildContent(), _buildFooter()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Iconsax.user, color: whiteColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.name, style: Tulisan.subheading(fontsize: 16)),
                const SizedBox(height: 2),
                Text(
                  request.phone,
                  style: Tulisan.body(
                    fontsize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              request.statusText,
              style: Tulisan.body(color: whiteColor, fontsize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Iconsax.location,
            title: 'Alamat',
            value: request.address,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Iconsax.routing,
            title: 'Jarak',
            value: '${request.distanceFromYou.toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Iconsax.clock,
            title: 'Waktu',
            value: request.requestedAt,
          ),
          const SizedBox(height: 12),
          _buildTrashItems(),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: Tulisan.body(fontsize: 13, color: Colors.grey.shade600),
        ),
        Expanded(child: Text(value, style: Tulisan.body(fontsize: 13))),
      ],
    );
  }

  Widget _buildTrashItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.trash, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'Detail Sampah:',
              style: Tulisan.body(fontsize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...request.trashItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.name} - ${item.weight.toStringAsFixed(1)} kg',
                        style: Tulisan.body(fontsize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
            ,
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Iconsax.weight, size: 16, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                'Total: ${request.totalWeight.toStringAsFixed(1)} kg',
                style: Tulisan.body(fontsize: 13, color: primaryColor),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Tap untuk detail',
                style: Tulisan.body(fontsize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              Icon(
                Iconsax.arrow_right_3,
                size: 14,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.cancelled:
        return Colors.red;
    }
  }
}
