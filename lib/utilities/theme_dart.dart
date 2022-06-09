

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/utilities/TextStyles.dart';

class ThemeDatas{

  ThemeData appThemeData(context){
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: TextStyles.THEME_COLOR,
      primaryIconTheme: IconThemeData(color: Colors.black),
      accentColor: Colors.white,
      fontFamily: 'Poppins',
      backgroundColor: Color(0xffF5F5F5),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(12)),
          textStyle: MaterialStateProperty.all(TextStyles.white18Normal),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                TextStyles.white18Normal,
              ))),
      textTheme: TextTheme(
        headline1: TextStyles().black18Normal,
        headline2: TextStyles.black16Normal,
        headline3: TextStyles.subtitleThemeStyle(context),
        headline4: GoogleFonts.getFont("Poppins",
            textStyle:
            TextStyle(fontSize: 10.0.sp, color: Color(0xff4D4D4D))),
        headline6: GoogleFonts.getFont("Poppins",
            textStyle:
            TextStyle(fontSize: 32.0.sp, fontStyle: FontStyle.italic)),
        bodyText2: GoogleFonts.getFont("Poppins",
            textStyle: TextStyle(fontSize: 10.0.sp, fontFamily: 'Hind')),
      ),
    );
  }

}