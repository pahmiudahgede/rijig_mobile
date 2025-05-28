import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

enum ModalVariant { textVersion, imageVersion }

class CustomModalDialog extends StatelessWidget {
  final ModalVariant variant;

  final String title;
  final String content;
  final String? imageAsset;

  final int buttonCount;
  final Widget? button1;
  final Widget? button2;
  
  // Parameter boolean untuk mengontrol tampilan close icon
  final bool showCloseIcon;

  const CustomModalDialog({
    super.key,
    required this.variant,
    required this.title,
    required this.content,
    this.imageAsset,
    this.buttonCount = 0,
    this.button1,
    this.button2,
    this.showCloseIcon = true, // Default true untuk backward compatibility
  });

  static void show({
    required BuildContext context,
    required ModalVariant variant,
    required String title,
    required String content,
    String? imageAsset,
    int buttonCount = 0,
    Widget? button1,
    Widget? button2,
    bool showCloseIcon = true, // Parameter baru di static method
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 190),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: CustomModalDialog(
                  variant: variant,
                  title: title,
                  content: content,
                  imageAsset: imageAsset,
                  buttonCount: buttonCount,
                  button1: button1,
                  button2: button2,
                  showCloseIcon: showCloseIcon, // Pass parameter ke constructor
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final modalContent = Container(
      padding: PaddingCustom().paddingHorizontalVertical(20, 24),
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (variant == ModalVariant.imageVersion && imageAsset != null)
            Padding(
              padding: PaddingCustom().paddingOnly(bottom: 20),
              child: Image.asset(
                imageAsset!,
                width: MediaQuery.of(context).size.width * 0.6,
                fit: BoxFit.contain,
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: Tulisan.subheading(fontsize: 19)),
          ),
          Gap(8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(content, style: Tulisan.customText(fontsize: 14)),
          ),
          Gap(24),
          if (buttonCount == 1 && button1 != null) button1!,
          if (buttonCount == 2 && button1 != null && button2 != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: button2!),
                Gap(16),
                Expanded(child: button1!),
              ],
            ),
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        modalContent,
        // Kondisional untuk menampilkan close icon
        if (showCloseIcon)
          Positioned(
            top: -15,
            right: 5,
            child: GestureDetector(
              onTap: () => router.pop(),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: whiteColor,
                child: Icon(Icons.close, color: blackNavyColor),
              ),
            ),
          ),
      ],
    );
  }
}