import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TextStyles {
  static Color THEME_COLOR = Color(0xff0E78E0);

  static TextStyle buttonTextStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.normal));
  }

  static TextStyle titleLoginStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.normal));
  }

  static TextStyle subtitleLoginStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Color(0xff717171).withOpacity(0.6),
            fontSize: 10.sp,
            fontWeight: FontWeight.w500));
  }

  static TextStyle titleStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Color(0xff3B3B3B),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500));
  }

  static TextStyle subtitleThemeStyle(context) {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: TextStyles.THEME_COLOR,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400));
  }

  static TextStyle subtitleStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Color(0xff717171).withOpacity(0.6),
            fontSize: 10.sp,
            fontWeight: FontWeight.w500));
  }

  static TextStyle flatInfoButtonTextStyles(context) {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: TextStyles.THEME_COLOR,
            fontSize: 8.sp,
            fontWeight: FontWeight.w500));
  }

  static TextStyle flatInfoTextStyles(context) {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Color(0xff4D4D4D),
            fontSize: 8.sp,
            fontWeight: FontWeight.w500));
  }

  static TextStyle editTextHintStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Colors.grey, fontSize: 10.sp, fontWeight: FontWeight.w400));
  }

  static TextStyle editTextLabelStyle(context) {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: TextStyles.THEME_COLOR,
            fontSize: 10.sp,
            fontWeight: FontWeight.w400));
  }

  static TextStyle editTextValueStyle() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Color(0xff1D2226),
            fontSize: 10.sp,
            fontWeight: FontWeight.w400));
  }

  static TextStyle dialogPositiveButton(context) {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: TextStyles.THEME_COLOR,
            fontSize: 10.sp,
            fontWeight: FontWeight.normal));
  }

  static TextStyle dialogNegativeButton() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Colors.redAccent,
            fontSize: 10.sp,
            fontWeight: FontWeight.normal));
  }

  static TextStyle dialogNeutralButton() {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.normal));
  }

  static TextStyle white18Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.normal));
  static TextStyle white18Medium = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500));
  static TextStyle white16Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.normal));
  static TextStyle white14Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.normal));
  static TextStyle white14Bold = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold));
  static TextStyle theme14Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: TextStyles.THEME_COLOR,
          fontSize: 10.sp,
          fontWeight: FontWeight.normal));
  static TextStyle theme18Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: TextStyles.THEME_COLOR,
          fontSize: 14.sp,
          fontWeight: FontWeight.normal));
  static TextStyle theme18Bold = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: TextStyles.THEME_COLOR,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500));

  static TextStyle black14Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.normal));
  static TextStyle black16Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.normal));
  TextStyle black18Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal));
  TextStyle black12Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.black, fontSize: 8.sp, fontWeight: FontWeight.normal)); TextStyle grey12Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.grey, fontSize: 8.sp, fontWeight: FontWeight.normal));
  TextStyle grey22Bold = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          fontSize: 18.sp,
          color: Color(0xff3E3E3E),
          fontWeight: FontWeight.normal));
  TextStyle grey22Bold60Opacity = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          fontSize: 18.sp,
          color: Color(0xff3E3E3E).withOpacity(0.6),
          fontWeight: FontWeight.normal));

  static TextStyle theme22Bold(context) {
    return GoogleFonts.getFont('Poppins',
        textStyle: TextStyle(
            fontSize: 18.sp,
            color: TextStyles.THEME_COLOR,
            fontWeight: FontWeight.normal));
  }

  TextStyle black24Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.normal));
  static TextStyle smartBellText = GoogleFonts.getFont('Righteous',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.normal));
  TextStyle red14Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.red, fontSize: 10.sp, fontWeight: FontWeight.normal));
  TextStyle errorTextStyle = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.red, fontSize: 10.sp, fontWeight: FontWeight.normal));
  TextStyle scaffoldTextSize = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.normal));
  static TextStyle blueUnderline14Normal = GoogleFonts.getFont('Poppins',
      textStyle: TextStyle(
          color: Colors.blue, fontSize: 10.sp, fontWeight: FontWeight.normal,decoration: TextDecoration.underline));

}
