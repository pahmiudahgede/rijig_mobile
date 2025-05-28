import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class SecurityCodeScreen extends StatefulWidget {
  const SecurityCodeScreen({super.key});

  @override
  State<SecurityCodeScreen> createState() => _SecurityCodeScreenState();
}

class _SecurityCodeScreenState extends State<SecurityCodeScreen> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value) {
    if (value == "delete") {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
        textEditingController.text = currentText;
      }
    } else if (currentText.length < 6) {
      currentText += value;
      textEditingController.text = currentText;
    }

    if (currentText.length == 6) {
      _validatePin();
    }
  }

  void _validatePin() {
    debugPrint("PIN entered: $currentText");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("PIN: $currentText")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Padding(
          padding: PaddingCustom().paddingHorizontal(24),
          child: Column(
            children: [
              Gap(60),
              Text(
                'Masukkan PIN Kamu',
                style: Tulisan.heading(fontsize: 20, color: primaryColor),
                // style: TextStyle(
                //   fontSize: 20,
                //   fontWeight: FontWeight.w600,
                //   color: primaryColor,
                // ),
                textAlign: TextAlign.center,
              ),
              Gap(60),
              Padding(
                padding: PaddingCustom().paddingHorizontal(27),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: textEditingController,
                  readOnly: true,
                  obscureText: true,
                  obscuringCharacter: '.',
                  animationType: AnimationType.slide,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    borderRadius: BorderRadius.circular(25),
                    fieldHeight: 20,
                    fieldWidth: 20,
                    activeFillColor: primaryColor,
                    inactiveFillColor: greyColor,
                    selectedFillColor: primaryColor,
                    activeColor: primaryColor,
                    inactiveColor: greyColor,
                    selectedColor: blackNavyColor,
                  ),
                  animationDuration: const Duration(milliseconds: 200),
                  enableActiveFill: true,
                  onCompleted: (v) {
                    _validatePin();
                  },
                  onChanged: (value) {
                    currentText = value;
                  },
                ),
              ),
              Gap(40),
              Text(
                'Lupa PIN kamu?',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: blackNavyColor,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor,
                ),
              ),
              const Spacer(),
              _buildKeypad(),
              Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('1'),
              _buildKeypadButton('2'),
              _buildKeypadButton('3'),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Gap(80), _buildKeypadButton('0'), _buildDeleteButton()],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return GestureDetector(
      onTap: () => _onKeypadTap(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: Center(
          child: Text(
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

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () => _onKeypadTap('delete'),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor, width: 1),
        ),
        child: Center(
          child: Icon(Icons.backspace_outlined, color: primaryColor, size: 28),
        ),
      ),
    );
  }
}
