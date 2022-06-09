import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
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
  final bool _isAuthenticated;
  final Map<String, dynamic> recentDevice;

  MyApplication(this._isAuthenticated, this.recentDevice);

  @override
  State<MyApplication> createState() => _MyApplicationState();
}

class _MyApplicationState extends State<MyApplication> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugins(
          [AmplifyAuthCognito(), AmplifyAnalyticsPinpoint()]);

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException catch (e) {
    } on Exception catch (e) {}
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
            '/': (context) => widget._isAuthenticated
                ? widget.recentDevice != null
                    ? WifiConnectErrorScreen()
                    : ShowCase()
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
