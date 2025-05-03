import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/userpin_vmod.dart';

class VerifPinScreen extends StatefulWidget {
  const VerifPinScreen({super.key});

  @override
  VerifPinScreenState createState() => VerifPinScreenState();
}

class VerifPinScreenState extends State<VerifPinScreen> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final pinViewModel = Provider.of<PinViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Verifikasi PIN")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masukkan PIN yang sudah dibuat",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: "PIN"),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // String userId = 'user_id_here';
                String pin = _pinController.text;

                await pinViewModel.verifyPin(pin);
                if (pinViewModel.pinExists == true) {
                  router.go('/navigasi');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PIN yang anda masukkan salah')),
                  );
                }
              },
              child: Text("Verifikasi PIN"),
            ),
          ],
        ),
      ),
    );
  }
}
