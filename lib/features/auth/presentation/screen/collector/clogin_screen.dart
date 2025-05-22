import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';

class CloginScreen extends StatefulWidget {
  const CloginScreen({super.key});

  @override
  State<CloginScreen> createState() => _CloginScreenState();
}

class _CloginScreenState extends State<CloginScreen> {
  final TextEditingController cPhoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: PaddingCustom().paddingHorizontalVertical(15, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Selamat datang di aplikasi",
                      style: Tulisan.subheading(),
                    ),
                    Text("Rijig", style: Tulisan.heading(color: primaryColor)),
                    SizedBox(height: mediaQuery.size.height * 0.2),
                    Column(
                      children: [
                        Image.asset(
                          'assets/image/security.png',
                          width: mediaQuery.size.width * 0.35,
                        ),
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
                          textButton: "Kirim OTP",
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
                            // if (cPhoneController.text.isNotEmpty) {
                            //   debugPrint("send otp dipencet");
                            //   await viewModel.loginOrRegister(
                            //     cPhoneController.text,
                            //   );
                            //   if (viewModel.loginResponse != null) {
                            //     router.go(
                            //       "/verif-otp",
                            //       extra: cPhoneController.text,
                            //     );
                            //   }
                            // }
                          },
                          // loadingTrue: viewModel.isLoading,
                          usingRow: false,
                        ),
                      ],
                    ),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("kembali ke login sebagai:"),
                        TextButton(
                          onPressed: () => router.go('/login'),
                          child: Text("masyarakat?"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // return const Placeholder();
  }
}
