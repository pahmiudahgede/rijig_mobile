import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/viewmodel/userpin_vmod.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  SetPinScreenState createState() => SetPinScreenState();
}

class SetPinScreenState extends State<SetPinScreen> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final pinViewModel = Provider.of<PinViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Buat PIN Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Buat PIN Anda (6 digit)", style: TextStyle(fontSize: 18)),
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
                String pin = _pinController.text;

                await pinViewModel.createPin(pin);
                if (pinViewModel.pinExists == true) {
                  router.go('/navigasi');
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Gagal membuat PIN')));
                }
              },
              child: Text("Buat PIN"),
            ),
          ],
        ),
      ),
    );
  }
}
