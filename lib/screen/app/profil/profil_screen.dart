import 'package:flutter/material.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    final titleofscreen = "Profil";
    return Scaffold(
      body: Center(child: Text("ini adalah halaman $titleofscreen")),
    );
  }
}
