import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

class KtpFormScreen extends StatefulWidget {
  const KtpFormScreen({super.key});

  @override
  State<KtpFormScreen> createState() => _KtpFormScreenState();
}

class _KtpFormScreenState extends State<KtpFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _subdistrictController = TextEditingController();
  final _hamletController = TextEditingController();
  final _villageController = TextEditingController();
  final _neighbourhoodController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _jobController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  String? _selectedReligion;
  String? _selectedMaritalStatus;
  String? _selectedCitizenship;
  String? _selectedValidUntil;

  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final viewModel = context.read<PengepulAuthViewModel>();

    _nikController.text = viewModel.identificationNumber;
    _nameController.text = viewModel.fullname;
    _placeOfBirthController.text = viewModel.placeOfBirth;
    _dateOfBirthController.text = viewModel.dateOfBirth;
    _selectedGender = viewModel.gender.isNotEmpty ? viewModel.gender : null;
    _selectedBloodType =
        viewModel.bloodType.isNotEmpty ? viewModel.bloodType : null;
    _provinceController.text = viewModel.province;
    _districtController.text = viewModel.district;
    _subdistrictController.text = viewModel.subdistrict;
    _hamletController.text = viewModel.hamlet;
    _villageController.text = viewModel.village;
    _neighbourhoodController.text = viewModel.neighbourhood;
    _postalCodeController.text = viewModel.postalCode;
    _selectedReligion =
        viewModel.religion.isNotEmpty ? viewModel.religion : null;
    _selectedMaritalStatus =
        viewModel.maritalStatus.isNotEmpty ? viewModel.maritalStatus : null;
    _jobController.text = viewModel.job;
    _selectedCitizenship =
        viewModel.citizenship.isNotEmpty ? viewModel.citizenship : null;
    _selectedValidUntil =
        viewModel.validUntil.isNotEmpty ? viewModel.validUntil : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Data KTP'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PengepulAuthViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildProgressIndicator(),

              Expanded(child: _buildStepContent(viewModel)),

              _buildBottomNavigation(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Langkah ${_currentStep + 1} dari $_totalSteps',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Data Pribadi', style: _getStepLabelStyle(0)),
              Text('Alamat', style: _getStepLabelStyle(1)),
              Text('Foto KTP', style: _getStepLabelStyle(2)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _getStepLabelStyle(int step) {
    return TextStyle(
      fontSize: 12.sp,
      color: _currentStep >= step ? Colors.green : Colors.grey[400],
      fontWeight: _currentStep == step ? FontWeight.bold : FontWeight.normal,
    );
  }

  Widget _buildStepContent(PengepulAuthViewModel viewModel) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepTitle(),
            SizedBox(height: 16.h),

            if (_currentStep == 0) _buildPersonalDataStep(),
            if (_currentStep == 1) _buildAddressStep(),
            if (_currentStep == 2) _buildPhotoStep(viewModel),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle() {
    String title = '';
    String subtitle = '';

    switch (_currentStep) {
      case 0:
        title = 'Data Pribadi';
        subtitle = 'Masukkan data pribadi sesuai KTP Anda';
        break;
      case 1:
        title = 'Alamat Lengkap';
        subtitle = 'Masukkan alamat lengkap sesuai KTP Anda';
        break;
      case 2:
        title = 'Foto KTP';
        subtitle = 'Upload foto KTP yang jelas dan dapat dibaca';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPersonalDataStep() {
    return Column(
      children: [
        _buildTextFormField(
          controller: _nikController,
          label: 'NIK',
          hint: 'Masukkan 16 digit NIK',
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: KtpValidator.validateNik,
          onChanged:
              (value) => context
                  .read<PengepulAuthViewModel>()
                  .setIdentificationNumber(value),
        ),

        _buildTextFormField(
          controller: _nameController,
          label: 'Nama Lengkap',
          hint: 'Sesuai dengan KTP',
          validator:
              (value) =>
                  value?.isEmpty == true ? 'Nama tidak boleh kosong' : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setFullname(value),
        ),

        _buildTextFormField(
          controller: _placeOfBirthController,
          label: 'Tempat Lahir',
          hint: 'Contoh: Jakarta',
          validator:
              (value) =>
                  value?.isEmpty == true
                      ? 'Tempat lahir tidak boleh kosong'
                      : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setPlaceOfBirth(value),
        ),

        _buildDateFormField(),

        _buildDropdownFormField(
          label: 'Jenis Kelamin',
          value: _selectedGender,
          items: const ['laki-laki', 'perempuan'],
          onChanged: (value) {
            setState(() => _selectedGender = value);
            context.read<PengepulAuthViewModel>().setGender(value ?? '');
          },
        ),

        _buildDropdownFormField(
          label: 'Golongan Darah',
          value: _selectedBloodType,
          items: const ['a', 'b', 'ab', 'o'],
          onChanged: (value) {
            setState(() => _selectedBloodType = value);
            context.read<PengepulAuthViewModel>().setBloodType(value ?? '');
          },
        ),

        _buildDropdownFormField(
          label: 'Agama',
          value: _selectedReligion,
          items: const [
            'islam',
            'kristen',
            'katolik',
            'hindu',
            'buddha',
            'khonghucu',
          ],
          onChanged: (value) {
            setState(() => _selectedReligion = value);
            context.read<PengepulAuthViewModel>().setReligion(value ?? '');
          },
        ),

        _buildDropdownFormField(
          label: 'Status Perkawinan',
          value: _selectedMaritalStatus,
          items: const ['belum kawin', 'kawin', 'cerai hidup', 'cerai mati'],
          onChanged: (value) {
            setState(() => _selectedMaritalStatus = value);
            context.read<PengepulAuthViewModel>().setMaritalStatus(value ?? '');
          },
        ),

        _buildTextFormField(
          controller: _jobController,
          label: 'Pekerjaan',
          hint: 'Contoh: Wiraswasta',
          validator:
              (value) =>
                  value?.isEmpty == true
                      ? 'Pekerjaan tidak boleh kosong'
                      : null,
          onChanged:
              (value) => context.read<PengepulAuthViewModel>().setJob(value),
        ),

        _buildDropdownFormField(
          label: 'Kewarganegaraan',
          value: _selectedCitizenship,
          items: const ['wni', 'wna'],
          onChanged: (value) {
            setState(() => _selectedCitizenship = value);
            context.read<PengepulAuthViewModel>().setCitizenship(value ?? '');
          },
        ),

        _buildDropdownFormField(
          label: 'Berlaku Hingga',
          value: _selectedValidUntil,
          items: const ['seumur hidup'],
          onChanged: (value) {
            setState(() => _selectedValidUntil = value);
            context.read<PengepulAuthViewModel>().setValidUntil(value ?? '');
          },
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      children: [
        _buildTextFormField(
          controller: _provinceController,
          label: 'Provinsi',
          hint: 'Contoh: Jawa Timur',
          validator:
              (value) =>
                  value?.isEmpty == true ? 'Provinsi tidak boleh kosong' : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setProvince(value),
        ),

        _buildTextFormField(
          controller: _districtController,
          label: 'Kabupaten/Kota',
          hint: 'Contoh: Kab. Banyuwangi',
          validator:
              (value) =>
                  value?.isEmpty == true
                      ? 'Kabupaten/Kota tidak boleh kosong'
                      : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setDistrict(value),
        ),

        _buildTextFormField(
          controller: _subdistrictController,
          label: 'Kecamatan',
          hint: 'Contoh: Siliragung',
          validator:
              (value) =>
                  value?.isEmpty == true
                      ? 'Kecamatan tidak boleh kosong'
                      : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setSubdistrict(value),
        ),

        _buildTextFormField(
          controller: _hamletController,
          label: 'Dusun',
          hint: 'Contoh: Senepolor',
          validator:
              (value) =>
                  value?.isEmpty == true ? 'Dusun tidak boleh kosong' : null,
          onChanged:
              (value) => context.read<PengepulAuthViewModel>().setHamlet(value),
        ),

        _buildTextFormField(
          controller: _villageController,
          label: 'Kelurahan/Desa',
          hint: 'Contoh: Barurejo',
          validator:
              (value) =>
                  value?.isEmpty == true
                      ? 'Kelurahan/Desa tidak boleh kosong'
                      : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setVillage(value),
        ),

        _buildTextFormField(
          controller: _neighbourhoodController,
          label: 'RT/RW',
          hint: 'Contoh: RT 004 / RW 005',
          validator:
              (value) =>
                  value?.isEmpty == true ? 'RT/RW tidak boleh kosong' : null,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setNeighbourhood(value),
        ),

        _buildTextFormField(
          controller: _postalCodeController,
          label: 'Kode Pos',
          hint: 'Contoh: 68488',
          keyboardType: TextInputType.number,
          maxLength: 5,
          validator: KtpValidator.validatePostalCode,
          onChanged:
              (value) =>
                  context.read<PengepulAuthViewModel>().setPostalCode(value),
        ),
      ],
    );
  }

  Widget _buildPhotoStep(PengepulAuthViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.grey[50],
          ),
          child:
              viewModel.cardPhoto != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(viewModel.cardPhoto!, fit: BoxFit.cover),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 48.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Belum ada foto KTP',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
        ),

        SizedBox(height: 16.h),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera, viewModel),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery, viewModel),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeri'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Tips Foto KTP yang Baik:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '• Pastikan semua text dapat dibaca dengan jelas\n'
                '• Hindari bayangan atau refleksi\n'
                '• Foto dalam kondisi terang\n'
                '• Format JPG, JPEG, atau PNG\n'
                '• Ukuran maksimal 10MB',
                style: TextStyle(color: Colors.blue[700], fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        validator: validator,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.green),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildDateFormField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: _dateOfBirthController,
        readOnly: true,
        onTap: _selectDate,
        validator:
            (value) =>
                value?.isEmpty == true
                    ? 'Tanggal lahir tidak boleh kosong'
                    : null,
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          hintText: 'DD-MM-YYYY',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.green),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        validator: (value) => value == null ? '$label harus dipilih' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.green),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item.toUpperCase()),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBottomNavigation(PengepulAuthViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Sebelumnya'),
              ),
            ),

          if (_currentStep > 0) SizedBox(width: 12.w),

          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child:
                  viewModel.isLoading
                      ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        _currentStep == _totalSteps - 1
                            ? 'Submit'
                            : 'Selanjutnya',
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _scrollToTop();
      }
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _nikController.text.isNotEmpty &&
          _nameController.text.isNotEmpty &&
          _placeOfBirthController.text.isNotEmpty &&
          _dateOfBirthController.text.isNotEmpty &&
          _selectedGender != null &&
          _selectedBloodType != null &&
          _selectedReligion != null &&
          _selectedMaritalStatus != null &&
          _jobController.text.isNotEmpty &&
          _selectedCitizenship != null &&
          _selectedValidUntil != null;
    } else if (_currentStep == 1) {
      return _provinceController.text.isNotEmpty &&
          _districtController.text.isNotEmpty &&
          _subdistrictController.text.isNotEmpty &&
          _hamletController.text.isNotEmpty &&
          _villageController.text.isNotEmpty &&
          _neighbourhoodController.text.isNotEmpty &&
          _postalCodeController.text.isNotEmpty;
    } else if (_currentStep == 2) {
      return context.read<PengepulAuthViewModel>().cardPhoto != null;
    }
    return false;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      _dateOfBirthController.text = formattedDate;
      // ignore: use_build_context_synchronously
      context.read<PengepulAuthViewModel>().setDateOfBirth(formattedDate);
    }
  }

  Future<void> _pickImage(
    ImageSource source,
    PengepulAuthViewModel viewModel,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        final String? validation = KtpValidator.validateImageFile(imageFile);
        if (validation != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(validation), backgroundColor: Colors.red),
            );
          }
          return;
        }

        viewModel.setCardPhoto(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = context.read<PengepulAuthViewModel>();

    try {
      await viewModel.uploadKtp();

      if (viewModel.state == PengepulAuthState.ktpUploaded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.message),
              backgroundColor: Colors.green,
            ),
          );

          context.go('/pengepul-approval-waiting');
        }
      } else if (viewModel.state == PengepulAuthState.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _placeOfBirthController.dispose();
    _dateOfBirthController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _subdistrictController.dispose();
    _hamletController.dispose();
    _villageController.dispose();
    _neighbourhoodController.dispose();
    _postalCodeController.dispose();
    _jobController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
