import 'package:scoped_model/scoped_model.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/model/main_model.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/screen/MainPage.dart';
import 'package:smart_bell/screen/OtpVerifyScreen.dart';
import 'package:smart_bell/screen/RegisterationPage.dart';
import 'package:flutter/material.dart';
import 'package:smart_bell/screen/WifiConnectErrorScreen.dart';
import 'package:smart_bell/utilities/theme_dart.dart';
import 'package:smart_bell/widgets/ShowCase.dart';

// Amplify
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'amplifyconfiguration.dart';

class MyApplication extends StatefulWidget {
  final Map<String, dynamic> recentDevice;

  MyApplication(this.recentDevice);

  @override
  State<MyApplication> createState() => _MyApplicationState();
}

class _MyApplicationState extends State<MyApplication> {
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    _configurationHelper();
  }

  void _configurationHelper() async {
    await _configureAmplify();
  }

  checkSession() async {
    try {
      AuthSession session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        setState(() {
          authenticated = true;
        });
      }
    } catch (e) {
      // print('Could not fetch Session $e');
    }
  }

  Future<void> _configureAmplify() async {
    if (!Amplify.isConfigured) {
      try {
        await Amplify.addPlugin(AmplifyAuthCognito());
        await Amplify.configure(amplifyconfig);
        if (Amplify.isConfigured) {
          await checkSession();
        }
      } on AmplifyAlreadyConfiguredException {
        print(
            "Amplify was already configured. Looks like app restarted on android.");
      } catch (e) {
        // print("Oh No" + e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return ScopedModel<MainModel>(
        model: MainModel(),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              child: child,
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            );
          },
          theme: ThemeDatas().appThemeData(context),
          title: 'Smart Bell',
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => authenticated
                ? (widget.recentDevice != null
                    ? WifiConnectErrorScreen()
                    : ShowCase())
                : MainPage(),
            '/home': (context) => ShowCase(),
            '/main': (context) => MainPage(),
            '/login': (context) => LoginPage(),
            '/signUp': (context) => RegistrationPage(),
            '/otpVerify': (context) => OtpVerifyPage(),
          },
        ),
      );
    });
  }
}
