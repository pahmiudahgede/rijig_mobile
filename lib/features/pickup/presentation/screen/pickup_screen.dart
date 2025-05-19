import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class PickupScreen extends StatefulWidget {
  final dynamic data;
  const PickupScreen({super.key, required this.data});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "Request Method"),
      body: SafeArea(
        child: Padding(
          padding: PaddingCustom().paddingHorizontal(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardButtonOne(
                textButton: "otomatis",
                fontSized: 16.sp,
                color: primaryColor,
                colorText: whiteColor,
                borderRadius: 9,
                horizontal: double.infinity,
                vertical: 50,
                onTap: () {
                  router.go('/navigasi', extra: '/activity');
                },
              ),
              Gap(30),
              CardButtonOne(
                textButton: "manual pilih driver",
                fontSized: 16.sp,
                color: primaryColor,
                colorText: whiteColor,
                borderRadius: 9,
                horizontal: double.infinity,
                vertical: 50,
                onTap: () {
                  router.push('/pilihpengepul');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
