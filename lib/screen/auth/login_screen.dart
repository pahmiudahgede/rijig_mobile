import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/auth_vmod.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            if (userVM.authModel?.status == 200) {
              Future.delayed(Duration.zero, () {
                router.go('/verif-otp', extra: _phoneController.text);
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    errorText: userVM.errorMessage,
                  ),
                ),
                SizedBox(height: 20),
                userVM.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: () {
                        if (_phoneController.text.isNotEmpty) {
                          userVM.login(_phoneController.text);
                        }
                      },
                      child: Text('Send OTP'),
                    ),
                if (userVM.authModel != null)
                  Text(
                    userVM.authModel!.message,
                    style: TextStyle(
                      color:
                          userVM.authModel!.status == 200
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
