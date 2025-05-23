import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class CverifOtpScreen extends StatefulWidget {
  const CverifOtpScreen({super.key});

  @override
  State<CverifOtpScreen> createState() => _CotpScreenState();
}

class _CotpScreenState extends State<CverifOtpScreen> {
  final TextEditingController _cOtpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: PaddingCustom().paddingHorizontalVertical(15, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("OTP has been sent to 6287874527xxxx"),
                SizedBox(height: 20),
                PinCodeTextField(
                  controller: _cOtpController,
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: whiteColor,
                    inactiveFillColor: whiteColor,
                    selectedFillColor: whiteColor,
                    activeColor: blackNavyColor,
                    inactiveColor: blackNavyColor,
                    selectedColor: primaryColor,
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {},
                ),
                SizedBox(height: 20),
      
                CardButtonOne(
                  textButton: "lanjut",
      
                  fontSized: 16.sp,
                  colorText: whiteColor,
                  color: primaryColor,
                  borderRadius: 10,
                  horizontal: double.infinity,
                  vertical: 50,
                  onTap: () {
                    router.go("/verifidentity");
                  },
      
                  usingRow: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
