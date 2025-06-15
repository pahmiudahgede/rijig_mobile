import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class CardButtonOne extends StatelessWidget {
  final String textButton;
  final double fontSized;
  final Color colorText;
  final double borderRadius;
  final double horizontal;
  final double vertical;
  final Function() onTap;
  final Color? color;
  final BoxBorder? borderAll;
  final bool loadingTrue;
  final bool usingRow;
  final MainAxisSize mainAxisSize;
  final Widget? child;
  const CardButtonOne({
    super.key,
    required this.textButton,
    required this.fontSized,
    required this.colorText,
    required this.borderRadius,
    required this.horizontal,
    required this.vertical,
    required this.onTap,
    this.loadingTrue = false,
    this.usingRow = false,
    this.color,
    this.borderAll,
    this.mainAxisSize = MainAxisSize.max,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: vertical,
        width: horizontal,
        decoration: BoxDecoration(
          color: color ?? blackNavyColor,
          borderRadius: BorderRadius.circular(borderRadius).w,
          border: borderAll,
        ),
        margin: EdgeInsets.zero,
        child: Center(
          child:
              (!loadingTrue)
                  ? usingRow == false
                      ? Text(
                        textButton,
                        style: Tulisan.customText(
                          color: colorText,
                          fontWeight: extraBold,
                          fontsize: 16,
                        ),
                      )
                      : Row(
                        mainAxisSize: mainAxisSize,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textButton,
                            style: Tulisan.customText(
                              color: colorText,
                              fontsize: 14,
                            ),
                          ),
                          GapCustom().gapValue(10, false),
                          Container(child: child),
                        ],
                      )
                  : CircularProgressIndicator(
                    backgroundColor: whiteColor,
                    color: primaryColor,
                  ),
        ),
      ),
    );
  }
}
