import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';
import 'package:rijig_mobile/features/auth/presentation/screen/collector/controller/ktp_validator_controller.dart';

class IdentityValidationScreen extends StatefulWidget {
  const IdentityValidationScreen({super.key});

  @override
  State<IdentityValidationScreen> createState() =>
      _IdentityValidationScreenState();
}

class _IdentityValidationScreenState extends State<IdentityValidationScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late KtpValidatorController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = context.read<KtpValidatorController>();
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
    return AppBar(
      title: Text(
        'Validasi Identitas KTP',
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
    );
  }

  Widget _buildBody() {
    return Consumer<KtpValidatorController>(
      builder: (context, controller, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageUploadSection(controller),
              SizedBox(height: 24.h),
              if (controller.hasData) _buildFormSection(controller),
              _buildMessages(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUploadSection(KtpValidatorController controller) {
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.camera_alt, color: primaryColor, size: 24.w),
        ),
        SizedBox(width: 16.w),
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
              SizedBox(height: 4.h),
              Text(
                'Pastikan foto jelas dan tidak buram',
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

  Widget _buildImageSourceButtons(KtpValidatorController controller) {
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
        SizedBox(width: 16.w),
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

  Widget _buildProcessButton(KtpValidatorController controller) {
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

  Widget _buildProcessingIndicator(KtpValidatorController controller) {
    String statusText = '';
    double progress = 0.0;

    switch (controller.processingStatus) {
      case ProcessingStatus.preprocessing:
        statusText = 'Memproses gambar...';
        progress = 0.25;
        break;
      case ProcessingStatus.extracting:
        statusText = 'Membaca teks...';
        progress = 0.5;
        break;
      case ProcessingStatus.validating:
        statusText = 'Validasi NIK...';
        progress = 0.75;
        break;
      case ProcessingStatus.completed:
        statusText = 'Selesai!';
        progress = 1.0;
        break;
      default:
        statusText = 'Memulai...';
        progress = 0.1;
    }

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            statusText,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: medium,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: greyColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(KtpValidatorController controller) {
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.edit_document, color: Colors.green, size: 24.w),
        ),
        SizedBox(width: 16.w),
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
              SizedBox(height: 4.h),
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

  List<Widget> _buildFormFields(KtpValidatorController controller) {
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

  Widget _buildSaveButton(KtpValidatorController controller) {
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

  Widget _buildMessages(KtpValidatorController controller) {
    if (controller.errorMessage.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 16.h),
        padding: EdgeInsets.all(16.w),
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
        padding: EdgeInsets.all(16.w),
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

  Future<void> _handleSaveData(KtpValidatorController controller) async {
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
      create: (context) => KtpValidatorController(),
      child: const IdentityValidationScreen(),
    );
  }
}
