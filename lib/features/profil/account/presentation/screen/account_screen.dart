import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';
import 'package:rijig_mobile/widget/custom_bottom_sheet.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = '';
  DateTime? _selectedDate;

  // Expanded states for each card
  bool _isNameExpanded = false;
  bool _isPhoneExpanded = false;
  bool _isGenderExpanded = false;
  bool _isBirthDateExpanded = false;

  // Loading states
  bool _isNameLoading = false;
  bool _isPhoneLoading = false;
  bool _isGenderLoading = false;
  bool _isBirthDateLoading = false;

  // Change detection states
  bool _hasNameChanged = false;
  bool _hasPhoneChanged = false;
  bool _hasGenderChanged = false;
  bool _hasBirthDateChanged = false;

  // Original values for comparison
  String _originalName = 'John Doe';
  String _originalPhone = '+62 812 3456 7890';
  String _originalGender = 'Laki-laki';
  DateTime? _originalBirthDate = DateTime(1990, 1, 15);

  // Current display values
  String _userName = 'John Doe';
  String _userPhone = '+62 812 3456 7890';
  String _userGender = 'Laki-laki';
  String _userBirthDate = '15 Januari 1990';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _addChangeListeners();
  }

  void _initializeData() {
    _nameController.text = _originalName;
    _phoneController.text = _originalPhone;
    _selectedGender = _originalGender;
    _selectedDate = _originalBirthDate;
  }

  void _addChangeListeners() {
    _nameController.addListener(() {
      setState(() {
        _hasNameChanged = _nameController.text != _originalName;
      });
    });

    _phoneController.addListener(() {
      setState(() {
        _hasPhoneChanged = _phoneController.text != _originalPhone;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectProfilePhoto() {
    CustomBottomSheet.show(
      context: context,
      title: 'Pilih Foto Profil',
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPhotoOption(
            icon: Icons.camera_alt,
            label: 'Kamera',
            onTap: () {
              Navigator.pop(context);
              debugPrint('Open Camera');
            },
          ),
          _buildPhotoOption(
            icon: Icons.photo_library,
            label: 'Galeri',
            onTap: () {
              Navigator.pop(context);
              debugPrint('Open Gallery');
            },
          ),
        ],
      ),
      button1:
          Container(), // Empty container since we have custom buttons above
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: primaryColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  void _saveField(String field) {
    setState(() {
      switch (field) {
        case 'name':
          _isNameLoading = true;
          break;
        case 'gender':
          _isGenderLoading = true;
          break;
        case 'birthDate':
          _isBirthDateLoading = true;
          break;
      }
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Update the display values and reset loading/change states
        switch (field) {
          case 'name':
            _userName = _nameController.text;
            _originalName = _nameController.text;
            _hasNameChanged = false;
            _isNameExpanded = false;
            _isNameLoading = false;
            break;
          case 'gender':
            _userGender = _selectedGender;
            _originalGender = _selectedGender;
            _hasGenderChanged = false;
            _isGenderExpanded = false;
            _isGenderLoading = false;
            break;
          case 'birthDate':
            if (_selectedDate != null) {
              _userBirthDate =
                  '${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}';
              _originalBirthDate = _selectedDate;
            }
            _hasBirthDateChanged = false;
            _isBirthDateExpanded = false;
            _isBirthDateLoading = false;
            break;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Data berhasil disimpan'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
  }

  void _sendOTP() {
    setState(() {
      _isPhoneLoading = true;
    });

    // Simulate OTP sending
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPhoneLoading = false;
        // Update phone after successful OTP verification
        _userPhone = _phoneController.text;
        _originalPhone = _phoneController.text;
        _hasPhoneChanged = false;
        _isPhoneExpanded = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kode OTP telah dikirim ke nomor Anda'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      debugPrint('Send OTP to: ${_phoneController.text}');
      // TODO: Navigate to OTP verification screen
      // Navigator.pushNamed(context, '/otp-verification');
    });
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month];
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasBirthDateChanged = _selectedDate != _originalBirthDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: Text('Akun Saya', style: Tulisan.subheading()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Photo Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: const NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _selectProfilePhoto,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userPhone,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Information Cards
            _buildExpandableCard(
              title: 'Nama Lengkap',
              value: _userName,
              icon: Icons.person,
              isExpanded: _isNameExpanded,
              hasChanges: _hasNameChanged,
              onTap: () {
                setState(() {
                  _isNameExpanded = !_isNameExpanded;
                  _isPhoneExpanded = false;
                  _isGenderExpanded = false;
                  _isBirthDateExpanded = false;
                });
              },
              child: _buildNameForm(),
            ),

            const SizedBox(height: 12),

            _buildExpandableCard(
              title: 'Nomor Telepon',
              value: _userPhone,
              icon: Icons.phone,
              isExpanded: _isPhoneExpanded,
              hasChanges: _hasPhoneChanged,
              onTap: () {
                setState(() {
                  _isPhoneExpanded = !_isPhoneExpanded;
                  _isNameExpanded = false;
                  _isGenderExpanded = false;
                  _isBirthDateExpanded = false;
                });
              },
              child: _buildPhoneForm(),
            ),

            const SizedBox(height: 12),

            _buildExpandableCard(
              title: 'Jenis Kelamin',
              value: _userGender,
              icon: Icons.wc,
              isExpanded: _isGenderExpanded,
              hasChanges: _hasGenderChanged,
              onTap: () {
                setState(() {
                  _isGenderExpanded = !_isGenderExpanded;
                  _isNameExpanded = false;
                  _isPhoneExpanded = false;
                  _isBirthDateExpanded = false;
                });
              },
              child: _buildGenderForm(),
            ),

            const SizedBox(height: 12),

            _buildExpandableCard(
              title: 'Tanggal Lahir',
              value: _userBirthDate,
              icon: Icons.cake,
              isExpanded: _isBirthDateExpanded,
              hasChanges: _hasBirthDateChanged,
              onTap: () {
                setState(() {
                  _isBirthDateExpanded = !_isBirthDateExpanded;
                  _isNameExpanded = false;
                  _isPhoneExpanded = false;
                  _isGenderExpanded = false;
                });
              },
              child: _buildBirthDateForm(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isExpanded,
    required bool hasChanges,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (hasChanges) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Berubah',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildNameForm() {
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        FormFieldOne(
          controllers: _nameController,
          hintText: 'Nama Lengkap',
          placeholder: 'Masukkan nama lengkap',
          isRequired: true,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        CardButtonOne(
          textButton: 'Simpan',
          fontSized: 16,
          colorText: Colors.white,
          borderRadius: 8,
          horizontal: double.infinity,
          vertical: 45,
          color: _hasNameChanged ? primaryColor : Colors.grey.shade400,
          loadingTrue: _isNameLoading,
          onTap: _hasNameChanged ? () => _saveField('name') : () {},
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        FormFieldOne(
          controllers: _phoneController,
          hintText: 'Nomor Telepon',
          placeholder: 'Masukkan nomor telepon',
          keyboardType: TextInputType.phone,
          isRequired: true,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        CardButtonOne(
          textButton: 'Kirim OTP',
          fontSized: 16,
          colorText: Colors.white,
          borderRadius: 8,
          horizontal: double.infinity,
          vertical: 45,
          color: _hasPhoneChanged ? Colors.orange : Colors.grey.shade400,
          loadingTrue: _isPhoneLoading,
          onTap: _hasPhoneChanged ? _sendOTP : () {},
        ),
      ],
    );
  }

  Widget _buildGenderForm() {
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        Column(
          children: [
            RadioListTile<String>(
              title: const Text('Laki-laki'),
              value: 'Laki-laki',
              groupValue: _selectedGender,
              activeColor: primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                  _hasGenderChanged = _selectedGender != _originalGender;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Perempuan'),
              value: 'Perempuan',
              groupValue: _selectedGender,
              activeColor: primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                  _hasGenderChanged = _selectedGender != _originalGender;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        CardButtonOne(
          textButton: 'Simpan',
          fontSized: 16,
          colorText: Colors.white,
          borderRadius: 8,
          horizontal: double.infinity,
          vertical: 45,
          color: _hasGenderChanged ? primaryColor : Colors.grey.shade400,
          loadingTrue: _isGenderLoading,
          onTap: _hasGenderChanged ? () => _saveField('gender') : () {},
        ),
      ],
    );
  }

  Widget _buildBirthDateForm() {
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}'
                      : 'Pilih tanggal lahir',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _selectedDate != null
                            ? Colors.black
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CardButtonOne(
          textButton: 'Simpan',
          fontSized: 16,
          colorText: Colors.white,
          borderRadius: 8,
          horizontal: double.infinity,
          vertical: 45,
          color: _hasBirthDateChanged ? primaryColor : Colors.grey.shade400,
          loadingTrue: _isBirthDateLoading,
          onTap: _hasBirthDateChanged ? () => _saveField('birthDate') : () {},
        ),
      ],
    );
  }
}
