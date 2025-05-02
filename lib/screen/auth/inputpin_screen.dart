import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/guide.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/userpin_vmod.dart';

class UserPinScreen extends StatefulWidget {
  const UserPinScreen({super.key});

  @override
  State<UserPinScreen> createState() => _UserPinScreenState();
}

class _UserPinScreenState extends State<UserPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final pinViewModel = Provider.of<PinViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Buat PIN Pengguna")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Masukkan PIN'),
                obscureText: true,
                maxLength: 6,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'PIN harus diisi';
                  } else if (value.length != 6) {
                    return 'PIN harus 6 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final pin = _pinController.text;

                    bool pinCreated = await pinViewModel.checkPinStatus();

                    if (!pinCreated) {
                      bool pinSet = await pinViewModel.setPin(pin);
                      if (pinSet) {
                        router.go('/navigasi');
                      } else {
                        setState(() {
                          errorMessage = 'Gagal membuat PIN';
                        });
                      }
                    } else {
                      bool pinVerified = await pinViewModel.verifyPin(pin);
                      if (pinVerified) {
                        router.go('/navigasi');
                      } else {
                        setState(() {
                          errorMessage = 'PIN yang anda masukkan salah';
                        });
                      }
                    }
                  }
                },
                child: const Text('Kirim'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(errorMessage, style: TextStyle(color: redColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
