// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/home/presentation/components/about_comp.dart';
import 'package:rijig_mobile/features/home/presentation/components/article_list.dart';
import 'package:rijig_mobile/features/home/presentation/viewmodel/about_vmod.dart';
import 'package:rijig_mobile/globaldata/article/article_vmod.dart';
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
          await Provider.of<ArticleViewModel>(
            context,
            listen: false,
          ).loadArticles();
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
                            Icon(
                              Iconsax.notification_copy,
                              color: primaryColor,
                            ),
                            Gap(10),
                            Icon(Iconsax.message_copy, color: primaryColor),
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
                    icon: Iconsax.trash,
                    text: 'Sampah',
                    number: '245 kg',
                    onTap: () {},
                  ),
                  CardWithIcon(
                    icon: Iconsax.timer,
                    text: 'Process',
                    number: '1',
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
                  Gap(15),
                  ArticleScreen(),
                ],
              ),
              // Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
