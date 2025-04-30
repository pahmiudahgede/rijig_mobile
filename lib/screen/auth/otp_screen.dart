import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/auth_vmod.dart';

class VerifotpScreen extends StatelessWidget {
  final String phone;
  final _otpController = TextEditingController();

  VerifotpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            if (userVM.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone: $phone', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),

                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    errorText: userVM.errorMessage,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String otp = _otpController.text;

                    if (otp.isNotEmpty) {
                      await Future.delayed(Duration(milliseconds: 50));
                      userVM.verifyOtp(phone, otp);

                      if (userVM.authModel?.status == 200) {
                        debugPrint("routing ke halaman home");
                        router.go('/home');
                      }
                    }
                  },
                  child: Text('Verify OTP'),
                ),

                if (userVM.errorMessage != null)
                  Text(
                    userVM.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
