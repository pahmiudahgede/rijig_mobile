import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/pengepul/stok/models/sampah_model.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class PenyetoranScreen extends StatefulWidget {
  const PenyetoranScreen({super.key});

  @override
  State<PenyetoranScreen> createState() => _PenyetoranScreenState();
}

class _PenyetoranScreenState extends State<PenyetoranScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beratController = TextEditingController();

  bool _isLoading = true;
  List<SampahStok> _stokSampah = [];
  SampahStok? _selectedSampah;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadStokSampah();
  }

  @override
  void dispose() {
    _beratController.dispose();
    super.dispose();
  }

  Future<void> _loadStokSampah() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _stokSampah =
          SampahDataService.getStokSampah().where((s) => s.jumlah > 0).toList();
      _isLoading = false;
    });
  }

  Future<void> _submitPenyetoran() async {
    if (!_formKey.currentState!.validate() || _selectedSampah == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.tick_circle, color: whiteColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Penyetoran ${_selectedSampah!.jenis} seberat ${_beratController.text} kg berhasil!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _beratController.clear();
    setState(() {
      _selectedSampah = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "setor"),
      body: RefreshIndicator(
        onRefresh: _loadStokSampah,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                _buildStokInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
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
            child: Icon(Iconsax.send_2, color: whiteColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setor Sampah',
                  style: Tulisan.subheading(color: whiteColor, fontsize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Setor sampah Anda ke pengelola',
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

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form Penyetoran', style: Tulisan.subheading(fontsize: 18)),
            const SizedBox(height: 20),
            _buildSampahDropdown(),
            const SizedBox(height: 16),
            _buildBeratInput(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSampahDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jenis Sampah', style: Tulisan.body(fontsize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              _isLoading
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : DropdownButtonFormField<SampahStok>(
                    value: _selectedSampah,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: 'Pilih jenis sampah',
                    ),
                    items:
                        _stokSampah.map((stok) {
                          return DropdownMenuItem<SampahStok>(
                            value: stok,
                            child: Row(
                              children: [
                                Icon(
                                  _getIconForType(stok.jenis),
                                  color: _getColorForType(stok.jenis),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(stok.jenis)),
                                Text(
                                  '${stok.jumlah.toStringAsFixed(1)} kg',
                                  style: Tulisan.body(
                                    fontsize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSampah = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih jenis sampah';
                      }
                      return null;
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildBeratInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Berat (kg)', style: Tulisan.body(fontsize: 14)),
            if (_selectedSampah != null) ...[
              const Spacer(),
              Text(
                'Stok: ${_selectedSampah!.jumlah.toStringAsFixed(1)} kg',
                style: Tulisan.body(fontsize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _beratController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: 'Masukkan berat sampah',
            suffixText: 'kg',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan berat sampah';
            }

            final berat = double.tryParse(value);
            if (berat == null || berat <= 0) {
              return 'Masukkan berat yang valid';
            }

            if (_selectedSampah != null && berat > _selectedSampah!.jumlah) {
              return 'Berat melebihi stok yang tersedia';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CardButtonOne(
      textButton: _isSubmitting ? 'Memproses...' : 'Setor Sekarang',
      fontSized: 16,
      colorText: whiteColor,
      color: _isSubmitting ? Colors.grey : primaryColor,
      borderRadius: 12,
      horizontal: double.infinity,
      vertical: 40,
      onTap: _isSubmitting ? () {} : _submitPenyetoran,
      usingRow: _isSubmitting,
    );
  }

  Widget _buildStokInfo() {
    if (_isLoading || _stokSampah.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.box, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Stok Tersedia', style: Tulisan.subheading(fontsize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ...(_stokSampah
              .take(3)
              .map(
                (stok) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForType(stok.jenis),
                        color: _getColorForType(stok.jenis),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stok.jenis,
                          style: Tulisan.body(fontsize: 14),
                        ),
                      ),
                      Text(
                        '${stok.jumlah.toStringAsFixed(1)} kg',
                        style: Tulisan.body(fontsize: 14, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              )
              .toList()),
          if (_stokSampah.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              'dan ${_stokSampah.length - 3} jenis lainnya...',
              style: Tulisan.body(fontsize: 12, color: Colors.grey.shade600),
            ),
          ],
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
