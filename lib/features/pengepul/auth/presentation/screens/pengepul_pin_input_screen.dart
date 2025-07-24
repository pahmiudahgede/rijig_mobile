import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/core/utils/validators.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

class PengepulPinInputScreen extends StatefulWidget {
  final bool isLogin;

  const PengepulPinInputScreen({super.key, required this.isLogin});

  @override
  State<PengepulPinInputScreen> createState() => _PengepulPinInputScreenState();
}

class _PengepulPinInputScreenState extends State<PengepulPinInputScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  String _currentPin = "";
  bool _isPinVisible = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializePin();
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _initializePin() {
    final viewModel = context.read<PengepulAuthViewModel>();
    final pin = viewModel.pin;

    if (pin.length == 6) {
      _currentPin = pin;
      _pinController.text = pin;
    }
  }

  void _onKeypadTap(String value) {
    final viewModel = context.read<PengepulAuthViewModel>();

    if (value == "delete") {
      if (_currentPin.isNotEmpty) {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        _pinController.text = _currentPin;
        viewModel.setPin(_currentPin);
      }
    } else if (_currentPin.length < 6) {
      _currentPin += value;
      _pinController.text = _currentPin;
      viewModel.setPin(_currentPin);
    }

    // Auto submit when PIN is complete
    if (_currentPin.length == 6) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleSubmit();
      });
    }
  }

  void _clearPin() {
    setState(() {
      _currentPin = "";
      _pinController.clear();
    });
    context.read<PengepulAuthViewModel>().setPin("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
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
            return Padding(
              padding: PaddingCustom().paddingHorizontal(24),
              child: Column(
                children: [
                  Gap(20),
                  _buildHeader(),
                  Gap(40),
                  _buildPinInput(viewModel),
                  Gap(20),
                  _buildVisibilityToggle(),
                  Gap(20),
                  if (viewModel.errorMessage.isNotEmpty) ...[
                    _buildErrorMessage(viewModel.errorMessage),
                    Gap(20),
                  ],
                  if (!widget.isLogin) ...[_buildInfoCard(), Gap(20)],
                  const Spacer(),
                  _buildKeypad(viewModel),
                  Gap(40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            widget.isLogin ? Icons.lock_open : Icons.lock_outline,
            size: 50.w,
            color: Colors.green,
          ),
        ),

        Gap(24),

        Text(
          widget.isLogin ? 'Masukkan PIN Anda' : 'Buat PIN Keamanan',
          style: Tulisan.heading(fontsize: 20, color: primaryColor),
          textAlign: TextAlign.center,
        ),

        Gap(8),

        Text(
          widget.isLogin
              ? 'Masukkan PIN 6 digit untuk masuk ke akun pengepul Anda'
              : 'Buat PIN 6 digit untuk keamanan akun pengepul Anda',
          style: Tulisan.subheading(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPinInput(PengepulAuthViewModel viewModel) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Padding(
            padding: PaddingCustom().paddingHorizontal(27),
            child: PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _pinController,
              readOnly: true, // Only accept input from custom keypad
              obscureText: !_isPinVisible,
              obscuringCharacter: '•',
              animationType: AnimationType.slide,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12.r),
                fieldHeight: 60.h,
                fieldWidth: 45.w,
                activeFillColor: whiteColor,
                inactiveFillColor: Colors.grey[50]!,
                selectedFillColor: whiteColor,
                activeColor: Colors.green,
                inactiveColor: Colors.grey[300]!,
                selectedColor: Colors.green,
                borderWidth: 2,
                errorBorderColor: Colors.red,
              ),
              animationDuration: const Duration(milliseconds: 200),
              enableActiveFill: true,
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              onCompleted: (value) {
                // Auto submit when PIN is complete
                _handleSubmit();
              },
              onChanged: (value) {
                _currentPin = value;
                viewModel.setPin(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisibilityToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _isPinVisible = !_isPinVisible;
            });
          },
          icon: Icon(
            _isPinVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
        ),
        Gap(8),
        Text(
          _isPinVisible ? 'Sembunyikan PIN' : 'Tampilkan PIN',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: PaddingCustom().paddingHorizontal(10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20.w),
          Gap(8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: PaddingCustom().paddingHorizontal(10),
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
              Icon(Icons.security, color: Colors.blue[600], size: 20.w),
              Gap(8),
              Text(
                'Keamanan PIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          Gap(12),
          Text(
            '• PIN harus terdiri dari 6 digit angka\n'
            '• Hindari menggunakan angka yang mudah ditebak\n'
            '• PIN akan digunakan untuk keamanan transaksi\n'
            '• Simpan PIN dengan aman dan jangan bagikan kepada siapapun',
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

  Widget _buildKeypad(PengepulAuthViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('1', viewModel),
              _buildKeypadButton('2', viewModel),
              _buildKeypadButton('3', viewModel),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('4', viewModel),
              _buildKeypadButton('5', viewModel),
              _buildKeypadButton('6', viewModel),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('7', viewModel),
              _buildKeypadButton('8', viewModel),
              _buildKeypadButton('9', viewModel),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(80),
              _buildKeypadButton('0', viewModel),
              _buildDeleteButton(viewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number, PengepulAuthViewModel viewModel) {
    bool isDisabled = viewModel.isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onKeypadTap(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey : Colors.green,
          shape: BoxShape.circle,
        ),
        child: Center(
          child:
              viewModel.isLoading && _currentPin.length == 6
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                    ),
                  )
                  : Text(
                    number,
                    style: Tulisan.customText(
                      color: whiteColor,
                      fontWeight: extraBold,
                      fontsize: 30,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(PengepulAuthViewModel viewModel) {
    bool isDisabled = viewModel.isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onKeypadTap('delete'),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.grey : Colors.green,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: isDisabled ? Colors.grey : Colors.green,
            size: 28,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final viewModel = context.read<PengepulAuthViewModel>();

    // Validate PIN
    final pinValidation = Validators.validatePin(viewModel.pin);
    if (pinValidation != null && !widget.isLogin) {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pinValidation), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      if (widget.isLogin) {
        await viewModel.verifyPin();

        if (viewModel.state == PengepulAuthState.authenticated) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.message),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to pengepul home
            context.go('/berandapengepul');
          }
        } else if (viewModel.state == PengepulAuthState.error) {
          _shakeController.forward().then((_) {
            _shakeController.reverse();
          });

          // Clear PIN on error for security
          _clearPin();
        }
      } else {
        await viewModel.createPin();

        if (viewModel.state == PengepulAuthState.pinCreated) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.message),
                backgroundColor: Colors.green,
              ),
            );

            // Show success dialog
            _showSuccessDialog();
          }
        }
      }
    } catch (e) {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 50.w,
                    color: Colors.green,
                  ),
                ),
                Gap(24),
                Text(
                  'Registrasi Berhasil!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(12),
                Text(
                  'Akun pengepul Anda telah berhasil dibuat. Anda dapat mulai menggunakan aplikasi sekarang.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/berandapengepul');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('Mulai Menggunakan Aplikasi'),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
