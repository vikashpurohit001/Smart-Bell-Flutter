import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:smart_bell/screen/DashboardScreen.dart';
import 'package:smart_bell/util/SessionManager.dart';

class ShowCase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        onStart: (index, key) {
          print('onStart: $index, $key');
        },
        onComplete: (index, key) {
          print('onComplete: $index, $key');
        },
        onFinish: () {
          print('onFinish:');
          SessionManager().setIsAppLaunch(false);
        },
        blurValue: 0,
        builder: Builder(builder: (context) => DashboardScreen()),
        autoPlay: false,
        autoPlayDelay: Duration(seconds: 3),
        autoPlayLockEnable: false,
      ),
    );
  }
}
