// ===lib/widget/showmodal.dart===
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

enum ModalVariant { textVersion, imageVersion, widgetSupportVersion }

class CustomModalDialog extends StatelessWidget {
  final ModalVariant variant;

  // Text and Image version properties
  final String? title;
  final String? content;
  final String? imageAsset;

  // Widget support version properties
  final Widget? customWidget;

  final int buttonCount;
  final Widget? button1;
  final Widget? button2;

  final bool showCloseIcon;

  const CustomModalDialog({
    super.key,
    required this.variant,
    this.title,
    this.content,
    this.imageAsset,
    this.customWidget,
    this.buttonCount = 0,
    this.button1,
    this.button2,
    this.showCloseIcon = true,
  }) : assert(
         variant == ModalVariant.widgetSupportVersion
             ? customWidget != null
             : (title != null && content != null),
         'For widgetSupportVersion, customWidget must be provided. '
         'For other variants, title and content must be provided.',
       );

  // Static method for text version
  static void showText({
    required BuildContext context,
    required String title,
    required String content,
    int buttonCount = 0,
    Widget? button1,
    Widget? button2,
    bool showCloseIcon = true,
  }) {
    _showModal(
      context: context,
      variant: ModalVariant.textVersion,
      title: title,
      content: content,
      buttonCount: buttonCount,
      button1: button1,
      button2: button2,
      showCloseIcon: showCloseIcon,
    );
  }

  // Static method for image version
  static void showImage({
    required BuildContext context,
    required String title,
    required String content,
    required String imageAsset,
    int buttonCount = 0,
    Widget? button1,
    Widget? button2,
    bool showCloseIcon = true,
  }) {
    _showModal(
      context: context,
      variant: ModalVariant.imageVersion,
      title: title,
      content: content,
      imageAsset: imageAsset,
      buttonCount: buttonCount,
      button1: button1,
      button2: button2,
      showCloseIcon: showCloseIcon,
    );
  }

  // Static method for widget support version
  static void showWidget({
    required BuildContext context,
    required Widget customWidget,
    int buttonCount = 0,
    Widget? button1,
    Widget? button2,
    bool showCloseIcon = true,
  }) {
    _showModal(
      context: context,
      variant: ModalVariant.widgetSupportVersion,
      customWidget: customWidget,
      buttonCount: buttonCount,
      button1: button1,
      button2: button2,
      showCloseIcon: showCloseIcon,
    );
  }

  // Private method to handle the modal display
  static void _showModal({
    required BuildContext context,
    required ModalVariant variant,
    String? title,
    String? content,
    String? imageAsset,
    Widget? customWidget,
    int buttonCount = 0,
    Widget? button1,
    Widget? button2,
    bool showCloseIcon = true,
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
                  customWidget: customWidget,
                  buttonCount: buttonCount,
                  button1: button1,
                  button2: button2,
                  showCloseIcon: showCloseIcon,
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
    Widget contentWidget;

    switch (variant) {
      case ModalVariant.textVersion:
        contentWidget = _buildTextContent();
        break;
      case ModalVariant.imageVersion:
        contentWidget = _buildImageContent(context);
        break;
      case ModalVariant.widgetSupportVersion:
        contentWidget = customWidget!;
        break;
    }

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
          contentWidget,
          if (buttonCount > 0) ...[const Gap(24), _buildButtons()],
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [modalContent, if (showCloseIcon) _buildCloseButton()],
    );
  }

  Widget _buildTextContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title!, style: Tulisan.subheading(fontsize: 19)),
        ),
        const Gap(8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(content!, style: Tulisan.customText(fontsize: 14)),
        ),
      ],
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageAsset != null) ...[
          Image.asset(
            imageAsset!,
            width: MediaQuery.of(context).size.width * 0.6,
            fit: BoxFit.contain,
          ),
          const Gap(20),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title!, style: Tulisan.subheading(fontsize: 19)),
        ),
        const Gap(8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(content!, style: Tulisan.customText(fontsize: 14)),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    if (buttonCount == 1 && button1 != null) {
      return button1!;
    } else if (buttonCount == 2 && button1 != null && button2 != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: button2!),
          const Gap(16),
          Expanded(child: button1!),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCloseButton() {
    return Positioned(
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
    );
  }
}
