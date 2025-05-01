import 'package:flutter/material.dart';
import 'package:rijig_mobile/widget/appbar.dart';

class RequestPickScreen extends StatelessWidget {
  const RequestPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "Pilih Sampah"),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Back to Home"),
        ),
      ),
    );
  }
}
