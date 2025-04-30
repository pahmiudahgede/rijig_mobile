import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rijig", style: TextStyle(fontSize: 24)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Iconsax.notification),
                    Gap(10),
                    Icon(Iconsax.message),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // IconBtnWithCounter(
          //   svgSrc: "assets/icons/Cart Icon.svg",
          //   press: () => Navigator.pushNamed(context, CartScreen.routeName),
          // ),
          // const SizedBox(width: 8),
          // IconBtnWithCounter(
          //   svgSrc: "assets/icons/Bell.svg",
          //   numOfitem: 3,
          //   press: () {},
          // ),
        ],
      ),
    );
  }
}
