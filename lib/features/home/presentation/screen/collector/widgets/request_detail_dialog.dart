// lib/features/home/presentation/widgets/request_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/home/model/c_request_list_dummymodel.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class RequestDetailDialog extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onConfirm;

  const RequestDetailDialog({
    super.key,
    required this.request,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(child: SingleChildScrollView(child: _buildContent())),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: whiteColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.user, color: whiteColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Request',
                  style: Tulisan.body(
                    color: whiteColor.withValues(alpha: 0.8),
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.name,
                  style: Tulisan.subheading(color: whiteColor, fontsize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          const SizedBox(height: 20),
          _buildTrashSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informasi Kontak', style: Tulisan.subheading(fontsize: 16)),
        const SizedBox(height: 12),
        _buildDetailRow(
          icon: Iconsax.call,
          title: 'Telepon',
          value: request.phone,
          actionIcon: Iconsax.copy,
          onActionTap: () {
          },
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          icon: Iconsax.location,
          title: 'Alamat',
          value: request.address,
          actionIcon: Iconsax.map,
          onActionTap: () {
          },
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          icon: Iconsax.routing,
          title: 'Jarak',
          value: '${request.distanceFromYou.toStringAsFixed(1)} km',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          icon: Iconsax.clock,
          title: 'Waktu Request',
          value: request.requestedAt,
        ),
      ],
    );
  }

  Widget _buildTrashSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Detail Sampah', style: Tulisan.subheading(fontsize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Total: ${request.totalWeight.toStringAsFixed(1)} kg',
                style: Tulisan.body(color: primaryColor, fontsize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...request.trashItems.map((item) => _buildTrashItem(item)),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    IconData? actionIcon,
    VoidCallback? onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Tulisan.body(
                    fontsize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: Tulisan.body(fontsize: 14)),
              ],
            ),
          ),
          if (actionIcon != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(actionIcon, size: 16, color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrashItem(TrashItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Iconsax.trash, size: 16, color: Colors.green.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.name, style: Tulisan.body(fontsize: 14))),
          Text(
            '${item.weight.toStringAsFixed(1)} kg',
            style: Tulisan.body(fontsize: 14, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Tutup',
                style: Tulisan.body(color: Colors.grey.shade600, fontsize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CardButtonOne(
              textButton: "Konfirmasi Pickup",
              fontSized: 14,
              colorText: whiteColor,
              color: primaryColor,
              borderRadius: 10,
              horizontal: double.infinity,
              vertical: 48,
              onTap: onConfirm,
              usingRow: false,
            ),
          ),
        ],
      ),
    );
  }
}
