// lib/features/pengepul/auth/presentation/screens/pengepul_phone_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';
import 'package:rijig_mobile/core/utils/validators.dart';

class PengepulPhoneInputScreen extends StatefulWidget {
  final bool isLogin;
  
  const PengepulPhoneInputScreen({
    super.key,
    required this.isLogin,
  });

  @override
  State<PengepulPhoneInputScreen> createState() => _PengepulPhoneInputScreenState();
}

class _PengepulPhoneInputScreenState extends State<PengepulPhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _initializePhone();
  }

  void _initializePhone() {
    final viewModel = context.read<PengepulAuthViewModel>();
    _phoneController.text = viewModel.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<PengepulAuthViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    _buildHeader(),
                    SizedBox(height: 40.h),
                    _buildRoleIndicator(),
                    SizedBox(height: 32.h),
                    _buildPhoneInput(viewModel),
                    SizedBox(height: 24.h),
                    if (!widget.isLogin) _buildTermsAndConditions(),
                    SizedBox(height: 32.h),
                    _buildSubmitButton(viewModel),
                    SizedBox(height: 24.h),
                    _buildAlternativeAction(),
                    if (viewModel.errorMessage.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildErrorMessage(viewModel.errorMessage),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo or Icon
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.recycling,
            size: 40.w,
            color: Colors.green,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        Text(
          widget.isLogin ? 'Masuk sebagai Pengepul' : 'Daftar sebagai Pengepul',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          widget.isLogin 
            ? 'Masuk ke akun pengepul Anda untuk mengakses fitur lengkap'
            : 'Daftarkan diri Anda sebagai pengepul sampah untuk mulai berkontribusi',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.business,
              color: Colors.white,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role: Pengepul',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  'Anda akan terdaftar sebagai pengepul sampah',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(PengepulAuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Telepon',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: Validators.validatePhone,
          onChanged: (value) {
            viewModel.setPhone(value);
          },
          decoration: InputDecoration(
            hintText: '628xxxxxxxxx',
            prefixIcon: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/indonesia_flag.png', // Add flag icon
                    width: 24.w,
                    height: 16.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 24.w,
                        height: 16.h,
                        color: Colors.red,
                        child: const Center(
                          child: Text('ID', style: TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '+62',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 1,
                    height: 20.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          'Masukkan nomor telepon yang aktif untuk menerima kode OTP',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Saya setuju dengan '),
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' dan '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' yang berlaku untuk pengepul.'),
                  ],
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Sebagai pengepul, Anda akan melewati proses verifikasi KTP yang memakan waktu hingga 24 jam.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(PengepulAuthViewModel viewModel) {
    final bool isFormValid = widget.isLogin 
        ? viewModel.isPhoneValid()
        : viewModel.isPhoneValid() && _agreedToTerms;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading || !isFormValid ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: viewModel.isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.isLogin ? 'Kirim Kode OTP' : 'Daftar Sekarang',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAlternativeAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.isLogin) {
              context.go('/pengepul-register');
            } else {
              context.go('/pengepul-login');
            }
          },
          child: Text(
            widget.isLogin ? 'Daftar di sini' : 'Masuk di sini',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.green,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<PengepulAuthViewModel>();
    
    try {
      if (widget.isLogin) {
        await viewModel.requestOtpLogin();
        
        if (viewModel.state == PengepulAuthState.otpSent) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.message),
                backgroundColor: Colors.green,
              ),
            );
            
            context.go('/pengepul-otp-verification?isLogin=true');
          }
        }
      } else {
        await viewModel.requestOtpRegister();
        
        if (viewModel.state == PengepulAuthState.otpSent) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.message),
                backgroundColor: Colors.green,
              ),
            );
            
            context.go('/pengepul-otp-verification?isLogin=false');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}