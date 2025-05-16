import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/launch/components/onboarding_comp.dart';
import 'package:rijig_mobile/features/launch/model/onboard_data.dart';

class OnboardingPageScreen extends StatefulWidget {
  const OnboardingPageScreen({super.key});

  @override
  OnboardingPageScreenState createState() => OnboardingPageScreenState();
}

class OnboardingPageScreenState extends State<OnboardingPageScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentIndex = _controller.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: [
          _currentIndex == 0 ? whiteColor : primaryColor,
          _currentIndex == 1 ? whiteColor : primaryColor,
          _currentIndex == 2 ? whiteColor : primaryColor,
        ],
        pageController: _controller,
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) {
          if (_currentIndex == OnboardingData.items.length - 1) {
            return InkWell(
              onTap: () => router.go('/login'),
              child: Center(
                child: Text(
                  "Go to Login",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: whiteColor,
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Icon(Icons.navigate_next, size: screenWidth * 0.08),
          );
        },
        itemCount: OnboardingData.items.length,
        scaleFactor: 2,
        duration: Duration(milliseconds: 500),
        itemBuilder: (index) {
          final page = OnboardingData.items[index];
          return SafeArea(child: OnboardingView(data: page));
        },
      ),
    );
  }
}
