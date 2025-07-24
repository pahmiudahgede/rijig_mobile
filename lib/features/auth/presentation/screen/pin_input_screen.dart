import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';

class PinInputScreen extends StatefulWidget {
  final bool isLogin;

  const PinInputScreen({super.key, required this.isLogin});

  @override
  State<PinInputScreen> createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _currentPin = "";
  bool _obscureText = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value) {
    final authViewModel = context.read<AuthViewModel>();

    if (value == "delete") {
      if (_currentPin.isNotEmpty) {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        _pinController.text = _currentPin;
        authViewModel.setPin(_currentPin);
      }
    } else if (_currentPin.length < 6) {
      _currentPin += value;
      _pinController.text = _currentPin;
      authViewModel.setPin(_currentPin);
    }

    // Auto submit when PIN is complete
    if (_currentPin.length == 6) {
      _submitPin();
    }
  }

  void _submitPin() {
    final authViewModel = context.read<AuthViewModel>();

    if (widget.isLogin) {
      authViewModel.verifyPin();
    } else {
      authViewModel.createPin();
    }
  }

  void _clearPin() {
    setState(() {
      _currentPin = "";
      _pinController.clear();
    });
    context.read<AuthViewModel>().setPin("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Handle navigation and error display (keeping original logic)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.state == AuthState.pinCreated ||
                authViewModel.state == AuthState.authenticated) {
              router.go('/navigasi');
            } else if (authViewModel.state == AuthState.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authViewModel.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
              // Clear PIN on error
              _clearPin();
            }
          });

          return SafeArea(
            child: Padding(
              padding: PaddingCustom().paddingHorizontal(24),
              child: Column(
                children: [
                  Gap(60),

                  // Header section
                  Text(
                    widget.isLogin ? 'Masukkan PIN Anda' : 'Buat PIN Keamanan',
                    style: Tulisan.heading(fontsize: 20, color: primaryColor),
                    textAlign: TextAlign.center,
                  ),

                  Gap(8),

                  Text(
                    widget.isLogin
                        ? 'Masukkan PIN 6 digit untuk masuk ke akun Anda'
                        : 'Buat PIN 6 digit untuk mengamankan akun Anda',
                    style: Tulisan.subheading(),
                    textAlign: TextAlign.center,
                  ),

                  Gap(60),

                  // PIN Code TextField using pin_code_fields
                  Padding(
                    padding: PaddingCustom().paddingHorizontal(27),
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _pinController,
                      readOnly: true, // Only accept input from custom keypad
                      obscureText: _obscureText,
                      obscuringCharacter: '•',
                      animationType: AnimationType.slide,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.circle,
                        borderRadius: BorderRadius.circular(25),
                        fieldHeight: 25,
                        fieldWidth: 25,
                        activeFillColor: primaryColor,
                        inactiveFillColor: greyColor,
                        selectedFillColor: primaryColor,
                        activeColor: primaryColor,
                        inactiveColor: greyColor,
                        selectedColor: blackNavyColor,
                      ),
                      animationDuration: const Duration(milliseconds: 200),
                      enableActiveFill: true,
                      onCompleted: (value) {
                        // Auto submit when PIN is complete
                        _submitPin();
                      },
                      onChanged: (value) {
                        _currentPin = value;
                        authViewModel.setPin(value);
                      },
                    ),
                  ),

                  Gap(30),

                  // Show/Hide PIN toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: !_obscureText,
                        onChanged: (value) {
                          setState(() {
                            _obscureText = !value!;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                      Text(
                        'Tampilkan PIN',
                        style: Tulisan.customText(fontsize: 12),
                      ),
                    ],
                  ),

                  Gap(20),

                  // Forgot PIN (only for login)
                  if (widget.isLogin)
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fitur lupa PIN akan segera tersedia',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Lupa PIN kamu?',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: blackNavyColor,
                          decoration: TextDecoration.underline,
                          decorationColor: primaryColor,
                        ),
                      ),
                    ),

                  // Info box for create PIN
                  if (!widget.isLogin) ...[
                    Gap(20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: PaddingCustom().paddingHorizontal(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600),
                          Gap(12),
                          Expanded(
                            child: Text(
                              'PIN ini akan digunakan untuk masuk ke akun dan mengamankan transaksi Anda. Harap simpan dengan baik.',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Custom Keypad
                  _buildKeypad(authViewModel),

                  Gap(40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeypad(AuthViewModel authViewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('1', authViewModel),
              _buildKeypadButton('2', authViewModel),
              _buildKeypadButton('3', authViewModel),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('4', authViewModel),
              _buildKeypadButton('5', authViewModel),
              _buildKeypadButton('6', authViewModel),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('7', authViewModel),
              _buildKeypadButton('8', authViewModel),
              _buildKeypadButton('9', authViewModel),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(80),
              _buildKeypadButton('0', authViewModel),
              _buildDeleteButton(authViewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number, AuthViewModel authViewModel) {
    bool isDisabled = authViewModel.isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onKeypadTap(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey : primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child:
              authViewModel.isLoading && _currentPin.length == 6
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

  Widget _buildDeleteButton(AuthViewModel authViewModel) {
    bool isDisabled = authViewModel.isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onKeypadTap('delete'),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.grey : primaryColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: isDisabled ? Colors.grey : primaryColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
