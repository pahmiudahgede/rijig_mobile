import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/auth_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class VerifotpScreen extends StatefulWidget {
  final dynamic phone;

  const VerifotpScreen({super.key, required this.phone});

  @override
  State<VerifotpScreen> createState() => _VerifotpScreenState();
}

class _VerifotpScreenState extends State<VerifotpScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: ${widget.phone}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),

              PinCodeTextField(
                controller: _otpController,
                length: 4,
                onChanged: (value) {},
                appContext: context,
                keyboardType: TextInputType.number,
                autoFocus: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  inactiveColor: Colors.black54,
                  activeColor: Colors.blue,
                  selectedColor: Colors.blue,
                ),
                animationType: AnimationType.fade,
                textStyle: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(height: 20),
              CardButtonOne(
                textButton: 'Verify OTP',
                fontSized: 16,
                colorText: Colors.white,
                borderRadius: 12,
                horizontal: double.infinity,
                vertical: 50,
                onTap: () {
                  if (_otpController.text.isNotEmpty) {
                    viewModel.verifyOtp(widget.phone, _otpController.text).then(
                      (_) {
                        if (viewModel.errorMessage == null) {
                          router.go('/navigasi');
                        } else {
                          debugPrint(viewModel.errorMessage ?? '');
                        }
                      },
                    );
                  }
                },
                loadingTrue: viewModel.isLoading,
                usingRow: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
