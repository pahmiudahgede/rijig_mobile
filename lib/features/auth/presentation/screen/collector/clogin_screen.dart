import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class CloginScreen extends StatefulWidget {
  const CloginScreen({super.key});

  @override
  CloginScreenState createState() => CloginScreenState();
}

class CloginScreenState extends State<CloginScreen> {
  final TextEditingController cPhoneController = TextEditingController();

  @override
  void dispose() {
    cPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
                        controllers: cPhoneController,
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
                        textButton: "kirim otp",
                        // viewModel.isLoading
                        //     ? 'Sending OTP...'
                        //     : 'Send OTP',
                        fontSized: 16.sp,
                        colorText: whiteColor,
                        color: primaryColor,
                        borderRadius: 10,
                        horizontal: double.infinity,
                        vertical: 50,
                        onTap: () {
                          if (cPhoneController.text.isNotEmpty) {
                            debugPrint("send otp dipencet");
                            router.go(
                              "/cverif-otp",
                              extra: cPhoneController.text,
                            );
                            // await viewModel.loginOrRegister(
                            //   cPhoneController.text,
                            // );
                            // if (viewModel.loginResponse != null) {
                            //   router.go(
                            //     "/verif-otp",
                            //     extra: cPhoneController.text,
                            //   );
                            // }
                          }
                        },
                        // loadingTrue: viewModel.isLoading,
                        usingRow: false,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("login sebagai:"),
                      TextButton(
                        onPressed: () => router.push('/login'),
                        child: Text("masyarakat?"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
