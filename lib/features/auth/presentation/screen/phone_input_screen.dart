import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class PhoneInputScreen extends StatefulWidget {
  final bool isLogin;

  const PhoneInputScreen({super.key, this.isLogin = false});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Custom validation method to maintain original logic
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    if (!value.startsWith('62')) {
      return 'Nomor telepon harus dimulai dengan 62';
    }
    if (value.length < 10 || value.length > 16) {
      return 'Nomor telepon harus 10-16 digit';
    }
    return null;
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
            if (authViewModel.state == AuthState.otpSent) {
              context.go('/xotp-verification?isLogin=${widget.isLogin}');
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
                      mediaQuery.size.height * 1 / 4 -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            // Header section
                            Text(
                              widget.isLogin
                                  ? 'Masuk ke Akun'
                                  : 'Buat Akun Baru',
                              style: Tulisan.heading(color: primaryColor),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Masukkan nomor telepon untuk ${widget.isLogin ? 'masuk' : 'mendaftar'}',
                              style: Tulisan.subheading(),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: mediaQuery.size.height * 0.1),

                            // Security image (adapting from friend's code)
                            Image.asset(
                              'assets/image/security.png',
                              width: mediaQuery.size.width * 0.35,
                            ),

                            SizedBox(height: 30),

                            // Phone input using FormFieldOne widget
                            FormFieldOne(
                              controllers: _phoneController,
                              hintText: 'Masukkan nomor telepon',
                              placeholder: "628123456789",
                              isRequired: true,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              onTap: () {},
                              onChanged: (value) {
                                authViewModel.setPhone(value);
                              },
                              fontSize: 14,
                              fontSizeField: 16,
                              onFieldSubmitted: (value) {},
                              readOnly: false,
                              enabled: true,
                              // Custom input formatters (maintaining original logic)
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.digitsOnly,
                              //   LengthLimitingTextInputFormatter(16),
                              // ],
                              // Custom validator (maintaining original logic)
                              validator: _validatePhone,
                            ),

                            SizedBox(height: 20),

                            // Send OTP button using CardButtonOne widget
                            CardButtonOne(
                              textButton:
                                  authViewModel.isLoading
                                      ? 'Mengirim OTP...'
                                      : 'Kirim Kode OTP',
                              fontSized: 16,
                              colorText: whiteColor,
                              color:
                                  (authViewModel.isLoading ||
                                          !authViewModel.isPhoneValid())
                                      ? Colors.grey
                                      : primaryColor,
                              borderRadius: 10,
                              horizontal: double.infinity,
                              vertical: 50,
                              // pada kodingan ini:
                              onTap:
                                  (authViewModel.isLoading ||
                                          !authViewModel.isPhoneValid())
                                      ? () {} // Empty function instead of null
                                      : () {
                                        if (_formKey.currentState!.validate()) {
                                          // Remove async/await and use then() instead
                                          if (widget.isLogin) {
                                            authViewModel.requestOtpLogin();
                                          } else {
                                            authViewModel.requestOtpRegister();
                                          }
                                        }
                                      },
                              loadingTrue: authViewModel.isLoading,
                              usingRow: false,
                            ),
                          ],
                        ),

                        // Bottom section with navigation options
                        Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                authViewModel.clearForm();
                                router.go(
                                  widget.isLogin ? '/xregister' : '/xlogin',
                                );
                              },
                              child: Text(
                                widget.isLogin
                                    ? 'Belum punya akun? Daftar di sini'
                                    : 'Sudah punya akun? Masuk di sini',
                                style: Tulisan.subheading(),
                              ),
                            ),

                            if (!widget.isLogin) ...[
                              SizedBox(height: 10),
                              Text(
                                'Dengan mendaftar, Anda menyetujui Syarat dan Ketentuan serta Kebijakan Privasi kami.',
                                style: Tulisan.customText(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
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
