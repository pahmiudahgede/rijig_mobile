import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/pengepul/stok/models/sampah_model.dart';
import 'package:rijig_mobile/widget/appbar.dart';

class StokSampahScreen extends StatefulWidget {
  const StokSampahScreen({super.key});

  @override
  State<StokSampahScreen> createState() => _StokSampahScreenState();
}

class _StokSampahScreenState extends State<StokSampahScreen> {
  bool _isLoading = true;
  List<SampahStok> _stokSampah = [];

  @override
  void initState() {
    super.initState();
    _loadStokSampah();
  }

  Future<void> _loadStokSampah() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _stokSampah = SampahDataService.getStokSampah();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "stok sampah"),
      body: RefreshIndicator(
        onRefresh: _loadStokSampah,
        child: _isLoading ? _buildLoadingState() : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [_buildHeader(), Expanded(child: _buildStokList())],
    );
  }

  Widget _buildHeader() {
    final totalStok = _stokSampah.fold(0.0, (sum, item) => sum + item.jumlah);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: whiteColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.box, color: whiteColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Stok Sampah',
                  style: Tulisan.body(
                    color: whiteColor.withValues(alpha: 0.8),
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalStok.toStringAsFixed(1)} kg',
                  style: Tulisan.heading(color: whiteColor, fontsize: 24),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whiteColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_stokSampah.length} Jenis',
              style: Tulisan.body(color: whiteColor, fontsize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildStokList() {
    if (_stokSampah.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _stokSampah.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stok = _stokSampah[index];
        return _buildStokCard(stok);
      },
    );
  }

  Widget _buildStokCard(SampahStok stok) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getColorForType(stok.jenis).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(stok.jenis),
                color: _getColorForType(stok.jenis),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stok.jenis, style: Tulisan.subheading(fontsize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    'Stok tersedia',
                    style: Tulisan.body(
                      fontsize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stok.jumlah.toStringAsFixed(1)} kg',
                  style: Tulisan.subheading(fontsize: 18, color: primaryColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(stok.jumlah),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusText(stok.jumlah),
                    style: Tulisan.body(color: whiteColor, fontsize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada stok sampah',
            style: Tulisan.subheading(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull untuk refresh',
            style: Tulisan.body(color: Colors.grey.shade500, fontsize: 14),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'plastik':
        return Iconsax.archive_book;
      case 'kertas':
        return Iconsax.document;
      case 'besi':
        return Iconsax.box_1;
      case 'kaca':
        return Iconsax.glass_1;
      default:
        return Iconsax.box;
    }
  }

  Color _getColorForType(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'plastik':
        return Colors.blue;
      case 'kertas':
        return Colors.orange;
      case 'besi':
        return Colors.grey;
      case 'kaca':
        return Colors.cyan;
      default:
        return primaryColor;
    }
  }

  Color _getStatusColor(double jumlah) {
    if (jumlah > 100) return Colors.green;
    if (jumlah > 50) return Colors.orange;
    return Colors.red;
  }

  String _getStatusText(double jumlah) {
    if (jumlah > 100) return 'Banyak';
    if (jumlah > 50) return 'Sedang';
    return 'Sedikit';
  }
}
