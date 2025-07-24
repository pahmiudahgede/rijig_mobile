import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/presentation/screen/collector/controller/ktp_validator_controller.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class OptimizedIdentityValidationScreen extends StatefulWidget {
  const OptimizedIdentityValidationScreen({super.key});

  @override
  State<OptimizedIdentityValidationScreen> createState() =>
      _OptimizedIdentityValidationScreenState();
}

class _OptimizedIdentityValidationScreenState
    extends State<OptimizedIdentityValidationScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late OptimizedKtpValidatorController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = context.read<OptimizedKtpValidatorController>();
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(judul: "Validasi Identitas KTP");
  }

  Widget _buildBody() {
    return Consumer<OptimizedKtpValidatorController>(
      builder: (context, controller, child) {
        return SingleChildScrollView(
          padding: PaddingCustom().paddingAll(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageUploadSection(controller),

              Gap(24.h),
              if (controller.nikCandidates.length > 1)
                _buildNIKCandidatesSection(controller),
              if (controller.nikCandidates.length > 1) Gap(24.h),
              if (controller.hasData) _buildFormSection(controller),
              _buildMessages(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUploadSection(OptimizedKtpValidatorController controller) {
    return Container(
      padding: PaddingCustom().paddingAll(20.w),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16.r),
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
          _buildUploadHeader(),
          Gap(24.h),
          if (controller.selectedImage != null)
            _buildImagePreview(controller.selectedImage!),
          Gap(24.h),
          _buildImageSourceButtons(controller),
          Gap(24.h),
          _buildProcessButton(controller),
          if (controller.isProcessing) _buildProcessingIndicator(controller),
        ],
      ),
    );
  }

  Widget _buildUploadHeader() {
    return Row(
      children: [
        Container(
          padding: PaddingCustom().paddingAll(12.w),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.camera_alt, color: primaryColor, size: 24.w),
        ),
        Gap(16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Foto KTP',
                style: Tulisan.customText(fontWeight: bold),
              ),
              Gap(4.h),
              Text(
                'Pastikan foto jelas dan tidak buram',
                style: Tulisan.customText(fontsize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(File image) {
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: greyColor.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.file(image, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildImageSourceButtons(OptimizedKtpValidatorController controller) {
    return Row(
      children: [
        Expanded(
          child: CardButtonOne(
            textButton: 'Kamera',
            fontSized: 14,
            colorText: primaryColor,
            borderRadius: 12,
            horizontal: double.infinity,
            vertical: 48.h,
            color: whiteColor,
            borderAll: Border.all(color: primaryColor, width: 1),
            onTap: controller.pickImageFromCamera,
            usingRow: true,
            child: Icon(Icons.camera_alt, color: primaryColor, size: 18.w),
          ),
        ),
        Gap(16.w),
        Expanded(
          child: CardButtonOne(
            textButton: 'Galeri',
            fontSized: 14,
            colorText: primaryColor,
            borderRadius: 12,
            horizontal: double.infinity,
            vertical: 48.h,
            color: whiteColor,
            borderAll: Border.all(color: primaryColor, width: 1),
            onTap: controller.pickImageFromGallery,
            usingRow: true,
            child: Icon(Icons.photo_library, color: primaryColor, size: 18.w),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessButton(OptimizedKtpValidatorController controller) {
    return CardButtonOne(
      textButton: controller.isProcessing ? 'Memproses...' : 'SCAN KTP',
      fontSized: 16,
      colorText: whiteColor,
      borderRadius: 12,
      horizontal: double.infinity,
      vertical: 52.h,
      color: controller.canProcessImage ? primaryColor : greyColor,
      loadingTrue: controller.isProcessing,
      onTap: controller.canProcessImage ? controller.processImage : () {},
    );
  }

  Widget _buildProcessingIndicator(OptimizedKtpValidatorController controller) {
    String statusText = '';
    double progress = 0.0;
    IconData statusIcon = Icons.hourglass_empty;

    switch (controller.processingStatus) {
      case ProcessingStatus.preprocessing:
        statusText = 'Memproses gambar...';
        progress = 0.25;
        statusIcon = Icons.image_search;
        break;
      case ProcessingStatus.extracting:
        statusText = 'Membaca teks...';
        progress = 0.5;
        statusIcon = Icons.text_fields;
        break;
      case ProcessingStatus.validating:
        statusText = 'Validasi NIK...';
        progress = 0.75;
        statusIcon = Icons.verified_user;
        break;
      case ProcessingStatus.completed:
        statusText = 'Selesai!';
        progress = 1.0;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusText = 'Memulai...';
        progress = 0.1;
        statusIcon = Icons.play_arrow;
    }

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: PaddingCustom().paddingAll(16.w),

      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: primaryColor, size: 20.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  statusText,
                  style: Tulisan.customText(
                    fontWeight: medium,
                    fontsize: 14,
                    color: primaryColor,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Tulisan.customText(
                  fontWeight: bold,
                  fontsize: 12,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: greyColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 4.h,
          ),
        ],
      ),
    );
  }

  Widget _buildNIKCandidatesSection(
    OptimizedKtpValidatorController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: PaddingCustom().paddingAll(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.search, color: Colors.orange, size: 24.w),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beberapa NIK Terdeteksi',
                      style: GoogleFonts.dmSans(
                        fontSize: 16.sp,
                        fontWeight: bold,
                        color: blackNavyColor,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      'Pilih NIK yang paling sesuai',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...controller.nikCandidates.asMap().entries.map((entry) {
            final index = entry.key;
            final nik = entry.value;
            final isSelected = nik == controller.ktpData.identificationNumber;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () => controller.selectNIKCandidate(nik),
                child: Container(
                  padding: PaddingCustom().paddingAll(16.w),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? primaryColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? primaryColor : greyColor,
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  color: whiteColor,
                                  size: 12.w,
                                )
                                : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nik,
                              style: GoogleFonts.dmSans(
                                fontSize: 16.sp,
                                fontWeight: isSelected ? bold : medium,
                                color:
                                    isSelected ? primaryColor : blackNavyColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Gap(4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: 14.w,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Kandidat ${index + 1}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'DIPILIH',
                            style: GoogleFonts.dmSans(
                              fontSize: 10.sp,
                              fontWeight: bold,
                              color: whiteColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFormSection(OptimizedKtpValidatorController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormHeader(),
            SizedBox(height: 24.h),
            ..._buildFormFields(controller),
            SizedBox(height: 24.h),
            _buildSaveButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      children: [
        Container(
          padding: PaddingCustom().paddingAll(12.w),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.edit_document, color: Colors.green, size: 24.w),
        ),
        Gap(16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data KTP Terdeteksi',
                style: GoogleFonts.dmSans(
                  fontSize: 18.sp,
                  fontWeight: bold,
                  color: blackNavyColor,
                ),
              ),
              Gap(4.h),
              Text(
                'Silakan periksa dan edit data jika diperlukan',
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: greyColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields(OptimizedKtpValidatorController controller) {
    return [
      _buildSectionTitle('Data Utama'),
      SizedBox(height: 12.h),

      FormFieldOne(
        hintText: 'NIK',
        controllers: controller.controllers['nik'],
        isRequired: true,
        keyboardType: TextInputType.number,
        maxLength: 16,
        onTap: () {},
        validator: (value) {
          if (value == null || value.length != 16) {
            return 'NIK harus 16 digit';
          }
          return null;
        },
      ),

      FormFieldOne(
        hintText: 'Nama Lengkap',
        controllers: controller.controllers['name'],
        isRequired: true,
        onTap: () {},
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nama lengkap harus diisi';
          }
          return null;
        },
      ),

      SizedBox(height: 20.h),
      _buildSectionTitle('Informasi Personal'),
      SizedBox(height: 12.h),

      Row(
        children: [
          Expanded(
            child: FormFieldOne(
              hintText: 'Tempat Lahir',
              controllers: controller.controllers['placeOfBirth'],
              isRequired: false,
              onTap: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FormFieldOne(
              hintText: 'Tanggal Lahir',
              controllers: controller.controllers['dateOfBirth'],
              isRequired: false,
              onTap: () {},
              placeholder: 'DD-MM-YYYY',
            ),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
            child: FormFieldOne(
              hintText: 'Jenis Kelamin',
              controllers: controller.controllers['gender'],
              isRequired: false,
              onTap: () {},
              placeholder: 'LAKI-LAKI / PEREMPUAN',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FormFieldOne(
              hintText: 'Golongan Darah',
              controllers: controller.controllers['bloodType'],
              isRequired: false,
              onTap: () {},
              placeholder: 'A, B, AB, O',
            ),
          ),
        ],
      ),

      SizedBox(height: 20.h),
      _buildSectionTitle('Alamat'),
      SizedBox(height: 12.h),

      FormFieldOne(
        hintText: 'RT/RW',
        controllers: controller.controllers['neighbourhood'],
        isRequired: false,
        onTap: () {},
        placeholder: 'Contoh: 001/002',
      ),

      Row(
        children: [
          Expanded(
            child: FormFieldOne(
              hintText: 'Desa/Kelurahan',
              controllers: controller.controllers['village'],
              isRequired: false,
              onTap: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FormFieldOne(
              hintText: 'Kecamatan',
              controllers: controller.controllers['subDistrict'],
              isRequired: false,
              enabled: false,
              inputColor: greyColor.withValues(alpha: 0.1),
              onTap: () {},
            ),
          ),
        ],
      ),

      SizedBox(height: 20.h),
      _buildSectionTitle('Informasi Lainnya'),
      SizedBox(height: 12.h),

      FormFieldOne(
        hintText: 'Agama',
        controllers: controller.controllers['religion'],
        isRequired: false,
        onTap: () {},
      ),

      FormFieldOne(
        hintText: 'Status Perkawinan',
        controllers: controller.controllers['maritalStatus'],
        isRequired: false,
        onTap: () {},
        placeholder: 'BELUM KAWIN / KAWIN / CERAI',
      ),

      FormFieldOne(
        hintText: 'Pekerjaan',
        controllers: controller.controllers['job'],
        isRequired: false,
        onTap: () {},
      ),

      Row(
        children: [
          Expanded(
            child: FormFieldOne(
              hintText: 'Kewarganegaraan',
              controllers: controller.controllers['citizenship'],
              isRequired: false,
              onTap: () {},
              placeholder: 'WNI / WNA',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FormFieldOne(
              hintText: 'Berlaku Hingga',
              controllers: controller.controllers['validUntil'],
              isRequired: false,
              onTap: () {},
              placeholder: 'SEUMUR HIDUP',
            ),
          ),
        ],
      ),

      SizedBox(height: 20.h),
      _buildSectionTitle('Data dari NIK Validator'),
      SizedBox(height: 12.h),

      FormFieldOne(
        hintText: 'Provinsi',
        controllers: controller.controllers['province'],
        isRequired: false,
        enabled: false,
        inputColor: greyColor.withValues(alpha: 0.1),
        onTap: () {},
      ),

      Row(
        children: [
          Expanded(
            child: FormFieldOne(
              hintText: 'Kabupaten/Kota',
              controllers: controller.controllers['district'],
              isRequired: false,
              enabled: false,
              inputColor: greyColor.withValues(alpha: 0.1),
              onTap: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FormFieldOne(
              hintText: 'Kode Pos',
              controllers: controller.controllers['postalCode'],
              isRequired: false,
              enabled: false,
              inputColor: greyColor.withValues(alpha: 0.1),
              onTap: () {},
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 16.sp,
        fontWeight: bold,
        color: blackNavyColor,
      ),
    );
  }

  Widget _buildSaveButton(OptimizedKtpValidatorController controller) {
    return CardButtonOne(
      textButton: 'SIMPAN DATA KTP',
      fontSized: 16,
      colorText: whiteColor,
      borderRadius: 12,
      horizontal: double.infinity,
      vertical: 52.h,
      color: primaryColor,
      onTap: () => _handleSaveData(controller),
    );
  }

  Widget _buildMessages(OptimizedKtpValidatorController controller) {
    if (controller.errorMessage.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 16.h),
        padding: PaddingCustom().paddingAll(16.w),
        decoration: BoxDecoration(
          color: redColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: redColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: redColor, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                controller.errorMessage,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: redColor,
                  fontWeight: medium,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.clearError,
              icon: Icon(Icons.close, color: redColor, size: 20.w),
            ),
          ],
        ),
      );
    }

    if (controller.successMessage.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 16.h),
        padding: PaddingCustom().paddingAll(16.w),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                controller.successMessage,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: Colors.green,
                  fontWeight: medium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _handleSaveData(
    OptimizedKtpValidatorController controller,
  ) async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.saveData();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: whiteColor),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Data KTP berhasil disimpan!',
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: medium,
                      color: whiteColor,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class UploadKtpScreen extends StatelessWidget {
  const UploadKtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OptimizedKtpValidatorController(),
      child: const OptimizedIdentityValidationScreen(),
    );
  }
}

class EnhancedUploadKtpScreen extends StatelessWidget {
  const EnhancedUploadKtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OptimizedKtpValidatorController(),
      child: const EnhancedIdentityValidationScreen(),
    );
  }
}

class EnhancedIdentityValidationScreen extends StatefulWidget {
  const EnhancedIdentityValidationScreen({super.key});

  @override
  State<EnhancedIdentityValidationScreen> createState() =>
      _EnhancedIdentityValidationScreenState();
}

class _EnhancedIdentityValidationScreenState
    extends State<EnhancedIdentityValidationScreen>
    with AutomaticKeepAliveClientMixin {
  late OptimizedKtpValidatorController _controller;
  bool _showAdvancedOptions = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = context.read<OptimizedKtpValidatorController>();
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: _buildEnhancedAppBar(),
      body: _buildEnhancedBody(),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      title: Text(
        'Validasi Identitas KTP Enhanced',
        style: GoogleFonts.dmSans(
          fontSize: 18.sp,
          fontWeight: bold,
          color: whiteColor,
        ),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: whiteColor),
        onPressed: () => router.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: whiteColor),
          onPressed: () {
            setState(() {
              _showAdvancedOptions = !_showAdvancedOptions;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedBody() {
    return Consumer<OptimizedKtpValidatorController>(
      builder: (context, controller, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showAdvancedOptions) _buildProcessingStats(controller),
              if (_showAdvancedOptions) SizedBox(height: 16.h),

              _buildImageUploadSection(controller),
              SizedBox(height: 24.h),

              if (controller.nikCandidates.length > 1)
                _buildEnhancedNIKCandidatesSection(controller),
              if (controller.nikCandidates.length > 1) SizedBox(height: 24.h),

              if (controller.hasData) _buildFormSection(controller),
              _buildMessages(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProcessingStats(OptimizedKtpValidatorController controller) {
    return Container(
      padding: PaddingCustom().paddingAll(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Processing Statistics',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Cache Status: ${controller.nikCandidates.isNotEmpty ? "Active" : "Empty"}',
            style: GoogleFonts.dmSans(fontSize: 12.sp, color: greyColor),
          ),
          Text(
            'Candidates Found: ${controller.nikCandidates.length}',
            style: GoogleFonts.dmSans(fontSize: 12.sp, color: greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNIKCandidatesSection(
    OptimizedKtpValidatorController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: PaddingCustom().paddingAll(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.psychology, color: Colors.orange, size: 24.w),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Detection Results',
                      style: GoogleFonts.dmSans(
                        fontSize: 16.sp,
                        fontWeight: bold,
                        color: blackNavyColor,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      '${controller.nikCandidates.length} NIK candidates dengan confidence scoring',
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...controller.nikCandidates.asMap().entries.map((entry) {
            final index = entry.key;
            final nik = entry.value;
            final isSelected = nik == controller.ktpData.identificationNumber;
            final isRecommended = index == 0;

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: () => controller.selectNIKCandidate(nik),
                child: Container(
                  padding: PaddingCustom().paddingAll(16.w),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? primaryColor.withValues(alpha: 0.1)
                            : isRecommended
                            ? Colors.green.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? primaryColor
                              : isRecommended
                              ? Colors.green.withValues(alpha: 0.5)
                              : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isSelected
                                      ? primaryColor
                                      : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? primaryColor : greyColor,
                                width: 2,
                              ),
                            ),
                            child:
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: whiteColor,
                                      size: 14.w,
                                    )
                                    : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nik,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16.sp,
                                          fontWeight:
                                              isSelected ? bold : medium,
                                          color:
                                              isSelected
                                                  ? primaryColor
                                                  : blackNavyColor,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    if (isRecommended)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Text(
                                          'RECOMMENDED',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 8.sp,
                                            fontWeight: bold,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Gap(4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.speed,
                                      color: Colors.blue,
                                      size: 12.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Rank ${index + 1}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11.sp,
                                        color: greyColor,
                                      ),
                                    ),
                                    Gap(16.w),
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 12.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Validated',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11.sp,
                                        color: greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10.sp,
                                  fontWeight: bold,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(OptimizedKtpValidatorController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16.r),
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
          _buildUploadHeader(),
          SizedBox(height: 20.h),
          if (controller.selectedImage != null)
            _buildImagePreview(controller.selectedImage!),
          SizedBox(height: 20.h),
          _buildImageSourceButtons(controller),
          SizedBox(height: 20.h),
          _buildProcessButton(controller),
          if (controller.isProcessing) _buildProcessingIndicator(controller),
        ],
      ),
    );
  }

  Widget _buildUploadHeader() {
    return Row(
      children: [
        Container(
          padding: PaddingCustom().paddingAll(12.w),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.camera_alt, color: primaryColor, size: 24.w),
        ),
        Gap(16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Foto KTP',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: bold,
                  color: blackNavyColor,
                ),
              ),
              Gap(4.h),
              Text(
                'AI-Powered Detection dengan akurasi tinggi',
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: greyColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(File image) {
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: greyColor.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.file(image, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildImageSourceButtons(OptimizedKtpValidatorController controller) {
    return Row(
      children: [
        Expanded(
          child: CardButtonOne(
            textButton: 'Kamera',
            fontSized: 14,
            colorText: primaryColor,
            borderRadius: 12,
            horizontal: double.infinity,
            vertical: 48.h,
            color: whiteColor,
            borderAll: Border.all(color: primaryColor, width: 1),
            onTap: controller.pickImageFromCamera,
            usingRow: true,
            child: Icon(Icons.camera_alt, color: primaryColor, size: 18.w),
          ),
        ),
        Gap(16.w),
        Expanded(
          child: CardButtonOne(
            textButton: 'Galeri',
            fontSized: 14,
            colorText: primaryColor,
            borderRadius: 12,
            horizontal: double.infinity,
            vertical: 48.h,
            color: whiteColor,
            borderAll: Border.all(color: primaryColor, width: 1),
            onTap: controller.pickImageFromGallery,
            usingRow: true,
            child: Icon(Icons.photo_library, color: primaryColor, size: 18.w),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessButton(OptimizedKtpValidatorController controller) {
    return CardButtonOne(
      textButton: controller.isProcessing ? 'AI Processing...' : 'SCAN KTP AI',
      fontSized: 16,
      colorText: whiteColor,
      borderRadius: 12,
      horizontal: double.infinity,
      vertical: 52.h,
      color: controller.canProcessImage ? primaryColor : greyColor,
      loadingTrue: controller.isProcessing,
      onTap: controller.canProcessImage ? controller.processImage : () {},
    );
  }

  Widget _buildProcessingIndicator(OptimizedKtpValidatorController controller) {
    String statusText = '';
    double progress = 0.0;
    IconData statusIcon = Icons.hourglass_empty;

    switch (controller.processingStatus) {
      case ProcessingStatus.preprocessing:
        statusText = 'AI Image Enhancement...';
        progress = 0.25;
        statusIcon = Icons.auto_fix_high;
        break;
      case ProcessingStatus.extracting:
        statusText = 'Neural Text Recognition...';
        progress = 0.5;
        statusIcon = Icons.psychology;
        break;
      case ProcessingStatus.validating:
        statusText = 'Smart NIK Validation...';
        progress = 0.75;
        statusIcon = Icons.verified_user;
        break;
      case ProcessingStatus.completed:
        statusText = 'Processing Complete!';
        progress = 1.0;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusText = 'Initializing AI...';
        progress = 0.1;
        statusIcon = Icons.rocket_launch;
    }

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: PaddingCustom().paddingAll(16.w),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: primaryColor, size: 20.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  statusText,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: medium,
                    color: primaryColor,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: greyColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 4.h,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(OptimizedKtpValidatorController controller) {
    return Container();
  }

  Widget _buildMessages(OptimizedKtpValidatorController controller) {
    return Container();
  }
}
