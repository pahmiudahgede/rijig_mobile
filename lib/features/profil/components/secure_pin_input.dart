import 'package:flutter/material.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [secondaryColor, primaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                Text(
                  'Masukkan Security Code Kamu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: whiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: textEditingController,
                  readOnly: true,
                  obscureText: true,

                  obscuringCharacter: '.',
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.circle,
                    borderRadius: BorderRadius.circular(25),
                    fieldHeight: 20,
                    fieldWidth: 20,
                    activeFillColor: whiteColor,
                    inactiveFillColor: whiteColor.withValues(alpha: 0.3),
                    selectedFillColor: whiteColor.withValues(alpha: 0.7),
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                    selectedColor: Colors.transparent,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onCompleted: (v) {
                    _validatePin();
                  },
                  onChanged: (value) {
                    currentText = value;
                  },
                ),

                const SizedBox(height: 40),

                Text(
                  'Lupa Security Code',
                  style: TextStyle(
                    fontSize: 16,
                    color: whiteColor,
                    decoration: TextDecoration.underline,
                    decorationColor: whiteColor,
                  ),
                ),

                const Spacer(),

                _buildKeypad(),

                const SizedBox(height: 40),
              ],
            ),
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
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 80),
              _buildKeypadButton('0'),
              _buildDeleteButton(),
            ],
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
        decoration: BoxDecoration(
          color: whiteColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: whiteColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: whiteColor,
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
          color: whiteColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: whiteColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(Icons.backspace_outlined, color: whiteColor, size: 24),
        ),
      ),
    );
  }
}
