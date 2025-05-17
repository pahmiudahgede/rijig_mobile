import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/home/presentation/components/about_comp.dart';
import 'package:rijig_mobile/features/home/presentation/viewmodel/about_vmod.dart';
import 'package:rijig_mobile/widget/card_withicon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: CustomMaterialIndicator(
        onRefresh: () async {
          await Provider.of<AboutViewModel>(
            context,
            listen: false,
          ).getAboutList();
        },
        backgroundColor: whiteColor,
        indicatorBuilder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: CircularProgressIndicator(
              color: primaryColor,
              value:
                  controller.state.isLoading
                      ? null
                      : math.min(controller.value, 1.0),
            ),
          );
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rijig",
                          style: Tulisan.heading(color: primaryColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Iconsax.notification),
                            Gap(10),
                            Icon(Iconsax.message_2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CardWithIcon(
                    icon: Icons.account_circle,
                    text: 'Users',
                    number: '245',
                    onTap: () {},
                  ),
                  CardWithIcon(
                    icon: Icons.shopping_cart,
                    text: 'Orders',
                    number: '178',
                    onTap: () {},
                  ),
                ],
              ),
              Gap(20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Important!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Gap(15),
                  AboutComponent(),
                ],
              ),
              Gap(20),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Artikel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
