import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/screen/RegisterationPage.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:smart_bell/widgets/ShowCase.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:sizer/sizer.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(false);
      Future.delayed(Duration.zero, () {
        checkSession();
      });
    }
  }

  checkSession() async {
    // try {
    //   AuthSession session = await Amplify.Auth.fetchAuthSession();
    //   if (session.isSignedIn) {
    //     Navigators.push(context, ShowCase());
    //   }
    // } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Widget backgroundWidget = Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/main_page_bg.png"),
              fit: BoxFit.cover)),
    );

    Widget loginWidget = ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.white),
      onPressed: () {
        Navigators.push(context, LoginPage());
      },
      child: Text('Login',
          style: GoogleFonts.getFont("Poppins",
              textStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.sp,
                  wordSpacing: 22,
                  fontWeight: FontWeight.w500))),
    );

    Widget registerWidget = ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          side: BorderSide(
            width: 1.0,
            color: Colors.white,
          ),
          primary: Colors.transparent,
        ),
        onPressed: () {
          Navigators.push(context, RegistrationPage());
        },
        child: Text(
          'Register',
          style: TextStyles.buttonTextStyle(),
        ));

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          backgroundWidget,
          SizedBox(
            width: double.maxFinite,
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(left: 5.h, right: 5.h, bottom: 7.h),
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset('assets/images/bell.json',
                              fit: BoxFit.fill, width: 15.w, height: 15.w),
                          Image.asset(
                            'assets/images/logo_bell.png',
                            fit: BoxFit.fill,
                            width: 25.w,
                            height: 25.w,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text('Smart Bell', style: TextStyles.smartBellText),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text('The time of tin tin has gone',
                              maxLines: 1, style: TextStyles.white14Normal),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: double.maxFinite, child: loginWidget),
                          SizedBox(
                            height: 2.h,
                          ),
                          SizedBox(
                              width: double.maxFinite, child: registerWidget),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
