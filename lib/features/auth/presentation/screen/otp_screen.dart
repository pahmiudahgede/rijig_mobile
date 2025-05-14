import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/otp_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class VerifOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifOtpScreen({super.key, required this.phoneNumber});

  @override
  VerifOtpScreenState createState() => VerifOtpScreenState();
}

class VerifOtpScreenState extends State<VerifOtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Consumer<OtpViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("OTP has been sent to ${widget.phoneNumber}"),
                SizedBox(height: 20),

                PinCodeTextField(
                  controller: _otpController,
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: Colors.black,
                    inactiveColor: Colors.black,
                    selectedColor: Colors.blue,
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {},
                ),
                SizedBox(height: 20),

                CardButtonOne(
                  textButton:
                      viewModel.isLoading ? 'Verifying OTP...' : 'Verify OTP',
                  fontSized: 16,
                  colorText: Colors.white,
                  borderRadius: 10,
                  horizontal: double.infinity,
                  vertical: 50,
                  onTap: () async {
                    if (_otpController.text.isNotEmpty) {
                      await viewModel.verifyOtp(
                        widget.phoneNumber,
                        _otpController.text,
                      );
                      if (viewModel.authResponse != null) {
                        router.go("/navigasi");
                      }
                    }
                  },
                  loadingTrue: viewModel.isLoading,
                  usingRow: false,
                ),

                if (viewModel.errorMessage != null)
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
