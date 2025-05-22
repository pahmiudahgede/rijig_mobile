import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/launch/model/onboard_model.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key, required this.data});

  final OnboardingModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Padding(
            padding: PaddingCustom().paddingOnly(top: 40),
            child: Image.asset(data.imagePath, fit: BoxFit.contain),
          ),
        ),
        Padding(
          padding: PaddingCustom().paddingAll(15),
          child: Column(
            children: [
              Text(data.headline, style: Tulisan.heading()),
              Padding(
                padding: PaddingCustom().paddingVertical(15),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: Tulisan.customText(fontsize: 14.sp),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      ],
    );
  }
}
