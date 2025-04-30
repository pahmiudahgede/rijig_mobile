import 'package:flutter/material.dart';
import 'package:rijig_mobile/screen/app/home/components/categories.dart';
import 'package:rijig_mobile/screen/app/home/components/discount_banner.dart';
import 'package:rijig_mobile/screen/app/home/components/home_header.dart';
import 'package:rijig_mobile/screen/app/home/components/popular_product.dart';
import 'package:rijig_mobile/screen/app/home/components/special_offers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final titleofscreen = "Home";
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HomeHeader(),
              DiscountBanner(),
              Categories(),
              SpecialOffers(),
              SizedBox(height: 20),
              PopularProducts(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
