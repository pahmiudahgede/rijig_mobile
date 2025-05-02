import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/auth_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Consumer<AuthViewModel>(
            builder: (context, userVM, child) {
              debugPrint('AuthModel Status: ${userVM.authModel?.status}');

              if (userVM.authModel?.status == 200 && !userVM.isLoading) {
                debugPrint(
                  'OTP Sent Successfully. Navigating to Verif-OTP Screen.',
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  router.go('/verif-otp', extra: _phoneController.text);
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormFieldOne(
                    controllers: _phoneController,
                    hintText: 'Phone Number',
                    isRequired: true,
                    onTap: () {},
                    keyboardType: TextInputType.phone,
                    errorText: userVM.errorMessage,
                  ),
                  const SizedBox(height: 20),

                  userVM.isLoading
                      ? CardButtonOne(
                        textButton: 'Sending OTP...',
                        fontSized: 16,
                        colorText: Colors.white,
                        borderRadius: 12,
                        horizontal: double.infinity,
                        vertical: 50,
                        onTap: () {},
                        loadingTrue: true,
                        usingRow: false,
                      )
                      : CardButtonOne(
                        textButton: 'Send OTP',
                        fontSized: 16,
                        colorText: Colors.white,
                        borderRadius: 12,
                        horizontal: double.infinity,
                        vertical: 50,
                        onTap: () {
                          if (_phoneController.text.isNotEmpty) {
                            debugPrint(
                              'Sending OTP to: ${_phoneController.text}',
                            );
                            userVM.login(_phoneController.text);
                          }
                        },
                        loadingTrue: false,
                        usingRow: false,
                      ),

                  if (userVM.authModel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        userVM.authModel!.message,
                        style: TextStyle(
                          color:
                              userVM.authModel!.status == 200
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
