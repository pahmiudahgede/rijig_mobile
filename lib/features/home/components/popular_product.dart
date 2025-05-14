import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/home/model/product.dart';
import 'package:rijig_mobile/features/home/components/product_card.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Artikel",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(demoProducts.length, (index) {
                if (demoProducts[index].isPopular) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ProductCard(
                      product: demoProducts[index],
                      onPress: () {},
                    ),
                  );
                }

                return const SizedBox.shrink(); // here by default width and height is 0
              }),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }
}
