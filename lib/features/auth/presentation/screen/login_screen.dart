import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/login_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    return Scaffold(
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: PaddingCustom().paddingHorizontalVertical(15, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldOne(
                  controllers: phoneController,
                  hintText: 'Phone Number',
                  isRequired: true,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  onTap: () {},
                  onChanged: (value) {},
                  fontSize: 14,
                  fontSizeField: 16,
                  onFieldSubmitted: (value) {},
                  readOnly: false,
                  enabled: true,
                ),
                SizedBox(height: 20),
                CardButtonOne(
                  textButton:
                      viewModel.isLoading ? 'Sending OTP...' : 'Send OTP',
                  fontSized: 16,
                  colorText: whiteColor,
                  borderRadius: 10,
                  horizontal: double.infinity,
                  vertical: 50,
                  onTap: () async {
                    if (phoneController.text.isNotEmpty) {
                      debugPrint("send otp dipencet");
                      await viewModel.loginOrRegister(phoneController.text);
                      if (viewModel.loginResponse != null) {
                        router.go("/verif-otp", extra: phoneController.text);
                      }
                    }
                  },
                  loadingTrue: viewModel.isLoading,
                  usingRow: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
