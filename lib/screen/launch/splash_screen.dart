import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/guide.dart';
import 'package:rijig_mobile/core/router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      router.go('/onboarding');
    });

    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/image/Go_Ride.png', height: 200),
          ),

          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 250.0),
              child: Text(
                'Rijig',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
