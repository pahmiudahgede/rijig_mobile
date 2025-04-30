import 'package:flutter/material.dart';

class RequestPickScreen extends StatelessWidget {
  const RequestPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Pickup")),
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
