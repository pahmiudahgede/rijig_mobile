import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/guide.dart';
import 'package:rijig_mobile/core/router.dart';

final pages = [
  const PageData(
    icon: Icons.food_bank_outlined,
    title: "Search for your favourite food",
    bgColor: Color(0xff3b1791),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.shopping_bag_outlined,
    title: "Add it to cart",
    bgColor: Color(0xfffab800),
    textColor: Color(0xff3b1790),
  ),
  const PageData(
    icon: Icons.delivery_dining,
    title: "Order and wait",
    bgColor: Color(0xffffffff),
    textColor: Color(0xff3b1790),
  ),
];

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
        colors: pages.map((p) => p.bgColor).toList(),
        pageController: _controller,
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) {
          if (_currentIndex == pages.length - 1) {
            return InkWell(
              onTap: () => router.go('/login'),
              child: Center(
                child: Text(
                  "Go to Login",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: whiteColor,
                  ),
                  // textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Icon(Icons.navigate_next, size: screenWidth * 0.08),
          );
        },
        itemCount: pages.length,
        scaleFactor: 2,
        duration: Duration(milliseconds: 500),
        itemBuilder: (index) {
          final page = pages[index];
          return SafeArea(child: _Page(page: page, index: index));
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;
  final int index;

  const _Page({required this.page, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.textColor,
          ),
          child: Icon(page.icon, size: screenHeight * 0.1, color: page.bgColor),
        ),
        Text(
          page.title ?? "",
          style: TextStyle(
            color: page.textColor,
            fontSize: screenHeight * 0.035,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
