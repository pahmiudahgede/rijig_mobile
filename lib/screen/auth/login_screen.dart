import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/guide.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/auth_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: PaddingCustom().paddingHorizontalVertical(15, 30),
          child: Consumer<AuthViewModel>(
            builder: (context, userVM, child) {
              if (userVM.authModel?.status == 200) {
                Future.delayed(Duration.zero, () {
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
                  SizedBox(height: 20),

                  userVM.isLoading
                      ? CircularProgressIndicator()
                      : CardButtonOne(
                        textButton: 'Send OTP',
                        fontSized: 16,
                        colorText: Colors.white,
                        borderRadius: 12,
                        horizontal: double.infinity,
                        vertical: 50,
                        onTap: () {
                          if (_phoneController.text.isNotEmpty) {
                            userVM.login(_phoneController.text);
                          }
                        },
                        loadingTrue: userVM.isLoading,
                        usingRow: false,
                      ),

                  if (userVM.authModel != null)
                    Text(
                      userVM.authModel!.message,
                      style: TextStyle(
                        color:
                            userVM.authModel!.status == 200
                                ? Colors.green
                                : Colors.red,
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
