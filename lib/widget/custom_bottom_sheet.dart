import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget button1;
  final Widget? button2;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.content,
    required this.button1,
    this.button2,
  });

  static void show({
    required BuildContext context,
    required String title,
    required Widget content,
    required Widget button1,
    Widget? button2,
    Duration duration = const Duration(milliseconds: 380),
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: duration,
      ),
      builder: (context) {
        return CustomBottomSheet(
          title: title,
          content: content,
          button1: button1,
          button2: button2,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: PaddingCustom().paddingAll(15),
          margin: const EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Tulisan.subheading(fontsize: 20)),
              const Gap(12),
              content,
              const Gap(24),
              if (button2 != null)
                Column(children: [button1, const Gap(12), button2!])
              else
                button1,
            ],
          ),
        ),
        Positioned(
          top: -25,
          right: 5,
          child: GestureDetector(
            onTap: () => router.pop(),
            child: Container(
              padding: PaddingCustom().paddingAll(10),
              decoration: BoxDecoration(
                color: whiteColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 25),
            ),
          ),
        ),
      ],
    );
  }
}
