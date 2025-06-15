import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _labelController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailController = TextEditingController();
  final _noteController = TextEditingController();

  final _labelFocus = FocusNode();
  final _recipientNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _detailFocus = FocusNode();
  final _noteFocus = FocusNode();

  bool _isDefault = false;
  bool _isLoading = false;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;

  final List<String> _provinces = [
    'DKI Jakarta',
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'Banten',
  ];

  final Map<String, List<String>> _cities = {
    'DKI Jakarta': [
      'Jakarta Pusat',
      'Jakarta Utara',
      'Jakarta Selatan',
      'Jakarta Timur',
      'Jakarta Barat',
    ],
    'Jawa Barat': ['Bandung', 'Bekasi', 'Bogor', 'Depok', 'Cimahi'],
    'Jawa Tengah': ['Semarang', 'Solo', 'Yogyakarta', 'Magelang', 'Salatiga'],
    'Jawa Timur': ['Surabaya', 'Malang', 'Kediri', 'Blitar', 'Madiun'],
    'Banten': ['Tangerang', 'Tangerang Selatan', 'Serang', 'Cilegon', 'Lebak'],
  };

  final Map<String, List<String>> _districts = {
    'Jakarta Pusat': [
      'Menteng',
      'Gambir',
      'Tanah Abang',
      'Senen',
      'Cempaka Putih',
    ],
    'Jakarta Selatan': [
      'Kebayoran Baru',
      'Kemang',
      'Kuningan',
      'Senayan',
      'Pondok Indah',
    ],
    'Bandung': ['Coblong', 'Sukasari', 'Cidadap', 'Dago', 'Antapani'],
    'Surabaya': ['Gubeng', 'Wonokromo', 'Tegalsari', 'Genteng', 'Bubutan'],
  };

  @override
  void dispose() {
    _labelController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailController.dispose();
    _noteController.dispose();
    _labelFocus.dispose();
    _recipientNameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _detailFocus.dispose();
    _noteFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _selectedProvince = value;
      _selectedCity = null;
      _selectedDistrict = null;
    });
  }

  void _onCityChanged(String? value) {
    setState(() {
      _selectedCity = value;
      _selectedDistrict = null;
    });
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      _selectedDistrict = value;
    });
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Alamat berhasil disimpan'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      router.pop(_buildFullAddress);
    }
  }

  String _buildFullAddress() {
    final parts = [
      _addressController.text,
      _detailController.text,
      _selectedDistrict,
      _selectedCity,
      _selectedProvince,
    ];
    return parts.where((part) => part != null && part.isNotEmpty).join(', ');
  }

  void _useCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Menggunakan lokasi saat ini...'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text('Tambah Alamat', style: Tulisan.subheading()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),

          onPressed: () => router.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lokasi Alamat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _useCurrentLocation,
                              icon: Icon(
                                Icons.my_location,
                                size: 18,
                                color: primaryColor,
                              ),
                              label: Text(
                                'Gunakan Lokasi Saat Ini',
                                style: TextStyle(color: primaryColor),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Alamat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _labelController,
                            focusNode: _labelFocus,
                            label: 'Label Alamat',
                            hint: 'Contoh: Rumah, Kantor, Kost',
                            icon: Icons.label,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Label alamat tidak boleh kosong';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_recipientNameFocus);
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _recipientNameController,
                            focusNode: _recipientNameFocus,
                            label: 'Nama Penerima',
                            hint: 'Masukkan nama lengkap penerima',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama penerima tidak boleh kosong';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_phoneFocus);
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            label: 'Nomor Telepon',
                            hint: 'Contoh: 08123456789',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon tidak boleh kosong';
                              }
                              if (value.length < 10) {
                                return 'Nomor telepon minimal 10 digit';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_addressFocus);
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildDropdown(
                            label: 'Provinsi',
                            value: _selectedProvince,
                            items: _provinces,
                            onChanged: _onProvinceChanged,
                            hint: 'Pilih Provinsi',
                            icon: Icons.location_city,
                          ),

                          const SizedBox(height: 16),

                          _buildDropdown(
                            label: 'Kota/Kabupaten',
                            value: _selectedCity,
                            items:
                                _selectedProvince != null
                                    ? _cities[_selectedProvince!] ?? []
                                    : [],
                            onChanged: _onCityChanged,
                            hint: 'Pilih Kota/Kabupaten',
                            icon: Icons.business,
                            enabled: _selectedProvince != null,
                          ),

                          const SizedBox(height: 16),

                          _buildDropdown(
                            label: 'Kecamatan',
                            value: _selectedDistrict,
                            items:
                                _selectedCity != null
                                    ? _districts[_selectedCity!] ?? []
                                    : [],
                            onChanged: _onDistrictChanged,
                            hint: 'Pilih Kecamatan',
                            icon: Icons.map,
                            enabled: _selectedCity != null,
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _addressController,
                            focusNode: _addressFocus,
                            label: 'Alamat Lengkap',
                            hint: 'Jalan, RT/RW, Kelurahan',
                            icon: Icons.home,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat lengkap tidak boleh kosong';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_detailFocus);
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _detailController,
                            focusNode: _detailFocus,
                            label: 'Detail Alamat (Opsional)',
                            hint: 'Patokan, warna rumah, nomor rumah, dll',
                            icon: Icons.info,
                            maxLines: 2,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_noteFocus);
                            },
                          ),

                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _noteController,
                            focusNode: _noteFocus,
                            label: 'Catatan untuk Kurir (Opsional)',
                            hint: 'Instruksi khusus untuk kurir',
                            icon: Icons.note,
                            maxLines: 2,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Checkbox(
                                value: _isDefault,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isDefault = value ?? false;
                                  });
                                },
                                activeColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Jadikan sebagai alamat utama',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Menyimpan...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                            : const Text(
                              'Simpan Alamat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: (value) {
            if (enabled && (value == null || value.isEmpty)) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
