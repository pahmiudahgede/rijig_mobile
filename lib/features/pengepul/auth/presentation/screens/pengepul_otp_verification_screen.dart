// lib/features/pengepul/auth/presentation/screens/pengepul_otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

class PengepulOtpVerificationScreen extends StatefulWidget {
  final bool isLogin;
  
  const PengepulOtpVerificationScreen({
    super.key,
    required this.isLogin,
  });

  @override
  State<PengepulOtpVerificationScreen> createState() => _PengepulOtpVerificationScreenState();
}

class _PengepulOtpVerificationScreenState extends State<PengepulOtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeOtp();
  }

  void _initializeOtp() {
    final viewModel = context.read<PengepulAuthViewModel>();
    final otp = viewModel.otp;
    
    if (otp.length == 4) {
      for (int i = 0; i < 4; i++) {
        _otpControllers[i].text = otp[i];
      }
    }
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResendOtp = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _canResendOtp = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Consumer<PengepulAuthViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(viewModel),
                  SizedBox(height: 40.h),
                  _buildOtpInput(viewModel),
                  SizedBox(height: 24.h),
                  _buildTimer(),
                  SizedBox(height: 32.h),
                  _buildVerifyButton(viewModel),
                  SizedBox(height: 16.h),
                  _buildResendButton(viewModel),
                  if (viewModel.errorMessage.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildErrorMessage(viewModel.errorMessage),
                  ],
                  SizedBox(height: 32.h),
                  _buildInfoCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(PengepulAuthViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.security,
            size: 50.w,
            color: Colors.green,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        Text(
          'Verifikasi OTP',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        
        SizedBox(height: 12.h),
        
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Kode OTP telah dikirim ke nomor\n'),
              TextSpan(
                text: _formatPhoneNumber(viewModel.phone),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput(PengepulAuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Masukkan Kode OTP',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16.h),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 60.w,
              height: 60.w,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
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
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  _handleOtpInput(value, index, viewModel);
                },
                onTap: () {
                  _otpControllers[index].clear();
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _canResendOtp ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _canResendOtp ? Colors.green[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _canResendOtp ? Icons.check_circle : Icons.access_time,
            size: 16.w,
            color: _canResendOtp ? Colors.green : Colors.grey[600],
          ),
          SizedBox(width: 8.w),
          Text(
            _canResendOtp 
                ? 'Bisa kirim ulang OTP'
                : 'Kirim ulang dalam ${_remainingSeconds}s',
            style: TextStyle(
              fontSize: 14.sp,
              color: _canResendOtp ? Colors.green[700] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(PengepulAuthViewModel viewModel) {
    final bool isOtpComplete = viewModel.isOtpValid();
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading || !isOtpComplete ? null : _handleVerify,
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
                'Verifikasi OTP',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendButton(PengepulAuthViewModel viewModel) {
    return TextButton.icon(
      onPressed: _canResendOtp && !viewModel.isLoading ? _handleResendOtp : null,
      icon: Icon(
        Icons.refresh,
        size: 18.w,
        color: _canResendOtp ? Colors.green : Colors.grey,
      ),
      label: Text(
        'Kirim Ulang Kode OTP',
        style: TextStyle(
          fontSize: 14.sp,
          color: _canResendOtp ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Informasi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.isLogin
                ? '• Masukkan kode OTP yang dikirim via SMS\n'
                  '• Kode berlaku selama 5 menit\n'
                  '• Jika tidak menerima SMS, tunggu 60 detik untuk kirim ulang'
                : '• Masukkan kode OTP yang dikirim via SMS\n'
                  '• Setelah verifikasi, Anda akan mengisi data KTP\n'
                  '• Proses verifikasi KTP memakan waktu hingga 24 jam',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _handleOtpInput(String value, int index, PengepulAuthViewModel viewModel) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Move to previous field when deleting
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    
    // Update OTP in viewmodel
    final otp = _otpControllers.map((controller) => controller.text).join();
    viewModel.setOtp(otp);
  }

  Future<void> _handleVerify() async {
    final viewModel = context.read<PengepulAuthViewModel>();
    
    try {
      if (widget.isLogin) {
        await viewModel.verifyOtpLogin();
        
        if (viewModel.state == PengepulAuthState.otpVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.message),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate to PIN input for login
            context.go('/pengepul-pin-input?isLogin=true');
          }
        }
      } else {
        await viewModel.verifyOtpRegister();
        
        if (viewModel.state == PengepulAuthState.otpVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.message),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate to KTP form for registration
            context.go('/pengepul-ktp-form');
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

  Future<void> _handleResendOtp() async {
    final viewModel = context.read<PengepulAuthViewModel>();
    
    try {
      // Clear current OTP
      for (final controller in _otpControllers) {
        controller.clear();
      }
      viewModel.setOtp('');
      
      // Request new OTP
      if (widget.isLogin) {
        await viewModel.requestOtpLogin();
      } else {
        await viewModel.requestOtpRegister();
      }
      
      if (viewModel.state == PengepulAuthState.otpSent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kode OTP baru telah dikirim'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Restart timer
          _startTimer();
          
          // Focus on first field
          _focusNodes[0].requestFocus();
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

  String _formatPhoneNumber(String phone) {
    if (phone.length >= 4) {
      final prefix = phone.substring(0, 4);
      final suffix = phone.length > 8 ? phone.substring(phone.length - 4) : '';
      final stars = '*' * (phone.length - 8);
      return '$prefix$stars$suffix';
    }
    return phone;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}