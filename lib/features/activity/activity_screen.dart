import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

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
      backgroundColor: whiteColor,
      body: Center(child: Text("ini adalah halaman $titleofscreen")),
    );
  }
}
