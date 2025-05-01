import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// =====================color schema=====================
Color whiteColor = Color(0xffF0F1EA);
Color blackNavyColor = Color(0xff101010);
Color primaryColor = Color(0xff018558);
Color secondaryColor = Color(0xffBDE902);
Color tersierColor = Color(0xffFEF031);
Color redColor = Color(0xffFF4438);
Color blueColor = Color(0xff00B5FF);
Color greyColor = Color(0xffCBD4E6);
Color greyAbsolutColor = Color(0xff5C707A);

// =====================font weight=====================
FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semiBold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
FontWeight extraBold = FontWeight.w900;
FontWeight superBold = FontWeight.w900;

// =====================text behavior=====================
class Tulisan {
  static TextStyle heading({Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 24.sp,
      fontWeight: FontWeight.bold,
      color: color ?? blackNavyColor,
    );
  }

  static TextStyle body({Color? color}) {
    return GoogleFonts.spaceMono(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: color ?? blackNavyColor,
    );
  }

  static TextStyle subheading({Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      color: color ?? blackNavyColor,
    );
  }
}

// =====================padding custom=====================
class PaddingCustom {
  paddingAll(double value) {
    return EdgeInsets.all(value.sp);
  }

  paddingHorizontalVertical(double horizontal, double vertical) {
    return EdgeInsets.symmetric(horizontal: horizontal.h, vertical: vertical.w);
  }

  paddingHorizontal(double horizontal) {
    return EdgeInsets.symmetric(horizontal: horizontal.h);
  }

  paddingVertical(double vertical) {
    return EdgeInsets.symmetric(vertical: vertical.w);
  }

  paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
      left: left.sp,
      top: top.sp,
      right: right.sp,
      bottom: bottom.sp,
    );
  }
}

// =====================gap behavior=====================
class GapCustom {
  gapValue(double value, bool columnTrue) {
    if (columnTrue == true) {
      return SizedBox(height: value.h);
    } else {
      return SizedBox(width: value.w);
    }
  }
}
