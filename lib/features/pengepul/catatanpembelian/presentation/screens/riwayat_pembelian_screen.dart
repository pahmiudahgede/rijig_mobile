import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/pengepul/stok/models/sampah_model.dart';
import 'package:rijig_mobile/widget/appbar.dart';

class RiwayatPembelianScreen extends StatefulWidget {
  const RiwayatPembelianScreen({super.key});

  @override
  State<RiwayatPembelianScreen> createState() => _RiwayatPembelianScreenState();
}

class _RiwayatPembelianScreenState extends State<RiwayatPembelianScreen> {
  bool _isLoading = true;
  List<TransaksiPembelian> _riwayatPembelian = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadRiwayatPembelian();
  }

  Future<void> _loadRiwayatPembelian() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _riwayatPembelian = TransaksiDataService.getRiwayatPembelian();
      _isLoading = false;
    });
  }

  List<TransaksiPembelian> get filteredTransaksi {
    if (_selectedFilter == 'Semua') return _riwayatPembelian;
    return _riwayatPembelian
        .where((t) => t.jenisSampah == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "riwayat pembelian"),
      body: RefreshIndicator(
        onRefresh: _loadRiwayatPembelian,
        child: _isLoading ? _buildLoadingState() : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildFilterSection(),
        Expanded(child: _buildRiwayatList()),
      ],
    );
  }

  Widget _buildHeader() {
    final totalTransaksi = _riwayatPembelian.length;
    final totalBerat = _riwayatPembelian.fold(
      0.0,
      (sum, item) => sum + item.berat,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
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
            child: Icon(Iconsax.document_1, color: whiteColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pembelian',
                  style: Tulisan.body(
                    color: whiteColor.withValues(alpha: 0.8),
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalTransaksi Transaksi',
                  style: Tulisan.subheading(color: whiteColor, fontsize: 18),
                ),
                Text(
                  '${totalBerat.toStringAsFixed(1)} kg',
                  style: Tulisan.body(
                    color: whiteColor.withValues(alpha: 0.8),
                    fontsize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final jenisOptions = [
      'Semua',
      ...Set.from(_riwayatPembelian.map((t) => t.jenisSampah)),
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: jenisOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final jenis = jenisOptions[index];
          final isSelected = _selectedFilter == jenis;

          return FilterChip(
            label: Text(jenis),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = jenis;
              });
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: primaryColor.withValues(alpha: 0.2),
            labelStyle: Tulisan.body(
              fontsize: 12,
              color: isSelected ? primaryColor : Colors.grey.shade700,
            ),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildRiwayatList() {
    final transaksi = filteredTransaksi;

    if (transaksi.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transaksi.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = transaksi[index];
        return _buildTransaksiCard(item);
      },
    );
  }

  Widget _buildTransaksiCard(TransaksiPembelian transaksi) {
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
      child: Column(
        children: [
          _buildTransaksiHeader(transaksi),
          _buildTransaksiContent(transaksi),
        ],
      ),
    );
  }

  Widget _buildTransaksiHeader(TransaksiPembelian transaksi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Iconsax.user, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.namaMasyarakat,
                  style: Tulisan.subheading(fontsize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  transaksi.tanggal,
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
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Selesai',
              style: Tulisan.body(color: Colors.green, fontsize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiContent(TransaksiPembelian transaksi) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getColorForType(
                transaksi.jenisSampah,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForType(transaksi.jenisSampah),
              color: _getColorForType(transaksi.jenisSampah),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.jenisSampah,
                  style: Tulisan.subheading(fontsize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dibeli dari masyarakat',
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
                '${transaksi.berat.toStringAsFixed(1)} kg',
                style: Tulisan.subheading(fontsize: 18, color: primaryColor),
              ),
              Text(
                'Rp ${transaksi.harga.toStringAsFixed(0)}',
                style: Tulisan.body(fontsize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_1, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat pembelian',
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
}
