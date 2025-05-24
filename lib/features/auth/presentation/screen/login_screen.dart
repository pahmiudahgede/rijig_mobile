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
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Selamat datang di aplikasi",
                            style: Tulisan.subheading(),
                          ),
                          Text(
                            "Rijig",
                            style: Tulisan.heading(color: primaryColor),
                          ),
                          SizedBox(height: mediaQuery.size.height * 0.1),
                          Image.asset(
                            'assets/image/security.png',
                            width: mediaQuery.size.width * 0.35,
                          ),
                          SizedBox(height: 30),
                          FormFieldOne(
                            controllers: phoneController,
                            hintText: 'Masukkan nomor whatsapp anda!',
                            placeholder: "cth.62..",
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
                                viewModel.isLoading
                                    ? 'Sending OTP...'
                                    : 'Send OTP',
                            fontSized: 16,
                            colorText: whiteColor,
                            color: primaryColor,
                            borderRadius: 10,
                            horizontal: double.infinity,
                            vertical: 50,
                            onTap: () async {
                              if (phoneController.text.isNotEmpty) {
                                debugPrint("send otp dipencet");
                                await viewModel.loginOrRegister(
                                  phoneController.text,
                                );
                                if (viewModel.loginResponse != null) {
                                  router.go(
                                    "/verif-otp",
                                    extra: phoneController.text,
                                  );
                                }
                              }
                            },
                            loadingTrue: viewModel.isLoading,
                            usingRow: false,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("login sebagai:"),
                              TextButton(
                                onPressed: () => router.push('/welcomec'),
                                child: Text("pengepul?"),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => router.push('/navigasi'),
                            child: Text("skip login"),
                          ),
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
