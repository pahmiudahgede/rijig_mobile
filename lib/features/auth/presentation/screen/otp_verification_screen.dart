import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class OtpVerificationScreen extends StatefulWidget {
  final bool isLogin;

  const OtpVerificationScreen({super.key, this.isLogin = false});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _submitOtp() {
    final authViewModel = context.read<AuthViewModel>();
    authViewModel.setOtp(_otpController.text);

    if (widget.isLogin) {
      authViewModel.verifyOtpLogin();
    } else {
      authViewModel.verifyOtpRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Handle navigation and error display (keeping original logic)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.state == AuthState.otpVerified) {
              if (authViewModel.nextStep == 'complete_personal_data') {
                router.go('/xprofile-form');
              } else if (authViewModel.nextStep == 'verif_pin') {
                router.go('/xpin-input?isLogin=true');
              }
            } else if (authViewModel.state == AuthState.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authViewModel.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });

          return SafeArea(
            child: SingleChildScrollView(
              padding: PaddingCustom().paddingHorizontalVertical(15, 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      mediaQuery.size.height -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: mediaQuery.size.height * 0.1),

                          // Header section
                          Text(
                            'Masukkan Kode OTP',
                            style: Tulisan.heading(color: primaryColor),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Kode OTP telah dikirim ke nomor\n+${authViewModel.phone}',
                            style: Tulisan.subheading(),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: mediaQuery.size.height * 0.08),

                          // Security/OTP icon (optional, similar to login screen)
                          Image.asset(
                            'assets/image/security.png',
                            width: mediaQuery.size.width * 0.25,
                          ),

                          SizedBox(height: 30),

                          // PIN Code TextField (using pin_code_fields like friend's code)
                          PinCodeTextField(
                            controller: _otpController,
                            appContext: context,
                            length: 4,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 60,
                              fieldWidth: 60,
                              activeFillColor: whiteColor,
                              inactiveFillColor: whiteColor,
                              selectedFillColor: whiteColor,
                              activeColor: blackNavyColor,
                              inactiveColor: blackNavyColor,
                              selectedColor: primaryColor,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              // Update authViewModel with OTP value
                              authViewModel.setOtp(value);
                            },
                            onCompleted: (value) {
                              // Auto submit when OTP is complete
                              if (value.length == 4) {
                                _submitOtp();
                              }
                            },
                          ),

                          SizedBox(height: 30),

                          // Verify button using CardButtonOne widget
                          CardButtonOne(
                            textButton:
                                authViewModel.isLoading
                                    ? 'Memverifikasi...'
                                    : 'Verifikasi',
                            fontSized: 16,
                            colorText: whiteColor,
                            color:
                                (authViewModel.isLoading ||
                                        !authViewModel.isOtpValid())
                                    ? Colors.grey
                                    : primaryColor,
                            borderRadius: 10,
                            horizontal: double.infinity,
                            vertical: 50,
                            onTap:
                                (authViewModel.isLoading ||
                                        !authViewModel.isOtpValid())
                                    ? () {}
                                    : () {
                                      if (_otpController.text.isNotEmpty) {
                                        _submitOtp();
                                      }
                                    },
                            loadingTrue: authViewModel.isLoading,
                            usingRow: false,
                          ),

                          SizedBox(height: 20),

                          // Resend OTP section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tidak menerima kode? ',
                                style: Tulisan.customText(fontsize: 12),
                              ),
                              TextButton(
                                onPressed:
                                    _canResend && !authViewModel.isLoading
                                        ? () {
                                          // Clear OTP field
                                          _otpController.clear();
                                          authViewModel.setOtp('');

                                          // Resend OTP
                                          if (widget.isLogin) {
                                            authViewModel.requestOtpLogin();
                                          } else {
                                            authViewModel.requestOtpRegister();
                                          }

                                          _startCountdown();
                                        }
                                        : () {},
                                child: Text(
                                  _canResend
                                      ? 'Kirim Ulang'
                                      : 'Kirim Ulang ($_countdown)',
                                  style: Tulisan.customText(
                                    fontsize: 12,
                                  ).copyWith(
                                    color:
                                        _canResend && !authViewModel.isLoading
                                            ? primaryColor
                                            : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Display error message if any
                          if (authViewModel.state == AuthState.error)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                authViewModel.errorMessage,
                                style: Tulisan.body().copyWith(
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),

                      // Bottom section
                      Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              authViewModel.clearForm();
                              router.go(
                                widget.isLogin ? '/xlogin' : '/xregister',
                              );
                            },
                            child: Text(
                              'Ganti Nomor Telepon',
                              style: Tulisan.subheading().copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
