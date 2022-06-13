import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/screen/WifiScanScreen.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';

class WifiDisplayColor extends StatelessWidget {
  String Username;

  WifiDisplayColor({Key key, this.Username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(3.0.h),
          child: Column(
            children: [
              Expanded(
                  child: Center(
                      child: Text(
                'Is your Smart Bell is plugged in and showing Yellow light?',
                style: TextStyles().black18Normal,
              ))),
              AppElevatedButtons(
                'Yes',
                onPressed: () {
                  Navigators.push(
                      context,
                      WifiScanScreen(
                        Username: Username,
                      ));
                },
              ),
              SizedBox(
                height: 0.5.h,
              ),
              TextButton(
                child: Text(
                  'No',
                  style: TextStyles().red14Normal,
                ),
                onPressed: () {
                  Navigators.pushReplacement(context, TurnOnResetButton());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TurnOnResetButton extends StatelessWidget {
  String Username;

  TurnOnResetButton({Key key, this.Username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/images/wifi_change.png';
    final Widget svgIcon = Image.asset(
      assetName,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(3.0.h),
          child: Column(
            children: [
              Expanded(
                  child: Center(
                      child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: double.minPositive,
                children: [
                  svgIcon,
                  Text(
                    'Press ON/OFF button and hold RESET button on Smart bell for few seconds until you see yellow light.',
                    style: TextStyles().black18Normal,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    'Tap Continue when light turned to yellow.',
                    style: TextStyles.black14Normal,
                  ),
                ],
              ))),
              AppElevatedButtons(
                'Continue',
                onPressed: () {
                  Navigators.push(
                      context,
                      WifiScanScreen(
                        Username: Username,
                      ));
                },
              ),
              SizedBox(
                height: 0.5.h,
              ),
              TextButton(
                child: Text(
                  'Cancel Setup',
                  style: TextStyles().red14Normal,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
