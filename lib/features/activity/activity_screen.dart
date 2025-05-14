import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final titleofscreen = "Aktivitas";
    return Scaffold(
      body: Center(child: Text("ini adalah halaman $titleofscreen")),
    );
  }
}
