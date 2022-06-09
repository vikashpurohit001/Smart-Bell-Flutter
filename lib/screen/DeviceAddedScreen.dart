import 'package:smart_bell/dao/DeviceBell.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:flutter/material.dart';

import 'SessionDataScreen.dart';

class DeviceAddedScreen extends StatelessWidget {
  String deviceToken, deviceId;
  bool isNewConnection;

  DeviceAddedScreen(
      {Key key, this.deviceToken, this.deviceId, this.isNewConnection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    TitleText(
                      isNewConnection ? 'Congratulation!!' : 'Yay!!',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SubtitleText(
                      isNewConnection
                          ? 'You have successfully connected Smart Bell'
                          : 'Wifi Authentication has been updated Successfully.',
                    ),
                  ],
                ),
              ),
              Image.asset('assets/images/connected_bg.png'),
              Text(
                'Turn Off Smart Bell Wifi and Connect with active Internet to add sessions.',
                style: TextStyles.black16Normal,
                textAlign: TextAlign.left,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppElevatedButtons(
                    isNewConnection ? 'Add Session' : 'View Sessions',
                    onPressed: () {
                      DeviceBell device = DeviceBell('');
                      Navigators.push(
                          context,
                          SessionDataScreen(
                            deviceToken: deviceToken,
                            deviceData: device,
                          ));
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
