import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class WelcomeCollectorScreen extends StatefulWidget {
  const WelcomeCollectorScreen({super.key});

  @override
  State<WelcomeCollectorScreen> createState() => _WelcomeSeekJobScreenState();
}

class _WelcomeSeekJobScreenState extends State<WelcomeCollectorScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Padding(
          padding: PaddingCustom().paddingHorizontal(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: Image.asset(
                    'assets/image/welcome_collector.png',
                    width: mediaQuery.size.width * 0.8,
                  ),
                ),
              ),
              Gap(20),
              Text(
                'Selamat datang pengepul!',
                style: Tulisan.heading(),
                textAlign: TextAlign.center,
              ),
              Gap(15),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: Tulisan.customText(
                  color: greyAbsolutColor,
                  fontsize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CardButtonOne(
                textButton: "Lanjut",
                fontSized: 16.sp,
                colorText: whiteColor,
                color: primaryColor,
                borderRadius: 10,
                horizontal: double.infinity,
                vertical: 50,
                onTap: () {
                  router.go("/clogin");
                },
                usingRow: false,
              ),
              Gap(30),
            ],
          ),
        ),
      ),
    );
  }
}
