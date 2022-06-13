import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/HomeScreen.dart';
import 'package:smart_bell/screen/WifiConnectErrorScreen.dart';
import 'package:smart_bell/screen/WifiScanScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/MethodChannelService.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:sizer/sizer.dart';

class SetUpDeviceScreen extends StatefulWidget {
  SetUpDeviceScreen({Key key}) : super(key: key);

  @override
  _SetUpDeviceScreenState createState() => _SetUpDeviceScreenState();
}

class _SetUpDeviceScreenState extends BaseState<SetUpDeviceScreen> {
  String name = "";
  bool isManual;
  TextEditingController deviceTitleController = TextEditingController();

  getName() async {
    name =
        '${await SessionManager().getFirstName()} ${await SessionManager().getLastName()}';
    setState(() {});
  }

  String getGreetings() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  showDeviceAddServerDialog(BuildContext mContext) {
    deviceTitleController.clear();
    showDialog<bool>(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
            title: TitleText('Add Device'),
            content: Card(
              color: Colors.transparent,
              elevation: 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InputTextField(
                    controller: deviceTitleController,
                    hint: 'Title',
                    label: 'Title',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyles.dialogNegativeButton(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  'Add Device',
                  style: TextStyles.dialogPositiveButton(context),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (deviceTitleController.text.isNotEmpty) {
                    showLoaderDialog(context);
                    RestServerApi.createDevice(deviceTitleController.text)
                        .then((response) {
                      hideLoader();
                      if (response['status'] == true) {
                        showSnackBar(response['message']);
                        Navigator.pop(context);
                      }
                    });
                  } else {}
                },
              ),
            ],
          ),
        );
      },
    );
  }

  askManualOrAutoConnect(String Username) async {
    SessionManager().saveRecentDeviceInfo(Username);
    showDialog<bool>(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
            title: Text(
              'Connect to Smart Bell',
              style: TextStyles.theme18Normal,
            ),
            content: Card(
              color: Colors.transparent,
              elevation: 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Do you want to auto Connect with Smart Bell or want to configure manually?',
                    style: TextStyles.black16Normal,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Note: Auto Connect might not work sometimes. Please use manual connection in order to connect.',
                    style: TextStyles.flatInfoTextStyles(context),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Auto Connect',
                  style: TextStyles.dialogNeutralButton(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  connectToWifi(Username);
                },
              ),
              TextButton(
                child: Text(
                  'Manually',
                  style: TextStyles.dialogPositiveButton(context),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigators.pushAndRemoveUntil(
                      context, WifiScanScreen(Username: Username));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  connectToWifi(String Username) async {
    String ssid = "Smart Bell";
    String password = "password";

    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(true);
    }
    bool canAutoConnect = true;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.model.toUpperCase().contains("ONEPLUS")) {
        canAutoConnect = false;
      }
    }
    if (canAutoConnect) {
      showLoaderDialog(context);
      CommonUtil.askLocationWithDisclosure(context, onClick: () {
        MethodChannelService()
            .connectToWifi(
          ssid,
          password,
        )
            .then((value) {
          if (value) {
            hideLoader();
            Navigators.pushAndRemoveUntil(
                context, WifiScanScreen(Username: Username));
          } else {
            hideLoader();
            Navigators.pushAndRemoveUntil(context, WifiConnectErrorScreen());
          }
        }).catchError((onError) {
          hideLoader();
          Navigators.pushAndRemoveUntil(
              context, WifiScanScreen(Username: Username));
        });
      });
    } else {
      showSnackBar(
          "Your Device is not compatible for auto connection. Try Manual Connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                        'Good ${getGreetings()}!',
                      ),
                      ThemeSubtitleText(
                        name,
                      ),
                    ],
                  ),
                ],
              ),
              Flexible(
                flex: 1,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.asset('assets/images/setup_bg.png'),
                    ImageNoteText(
                      'There are currently no devices added',
                    ),
                  ],
                ),
              ),
              AppElevatedButtons(
                'Set Up Device',
                onPressed: () {
                  _showWifiDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> isWifiEnabled() async {
    var connectivityResult;
    if (Platform.isAndroid) {
      connectivityResult = await WifiConfiguration().isWifiEnabled();
    } else {
      connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
    }
    return connectivityResult;
  }

  _showWifiDialog(context) async {
    bool isWifiEnableVal = await isWifiEnabled();
    if (!isWifiEnableVal) {
      showDialog(
          context: context,
          builder: (context) {
            return Theme(
              data: ThemeData(dialogBackgroundColor: Colors.white),
              child: Builder(
                builder: (context) {
                  return CupertinoAlertDialog(
                    content: new Text(
                        "You need to turn wifi on to scan for device. Turn it on now ?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.getFont("Poppins",
                                textStyle: TextStyle(
                                    color: Colors.red, fontSize: 12.sp)),
                          )),
                      TextButton(
                          onPressed: () async {
                            await WiFiForIoTPlugin.setEnabled(true,
                                shouldOpenSettings: true);
                            Navigator.of(context).pop();
                            redirectToWifiScreen(context);
                          },
                          child: Text('Turn On',
                              style: GoogleFonts.getFont("Poppins",
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12.sp))))
                    ],
                  );
                },
              ),
            );
          });
    } else {
      redirectToWifiScreen(context);
    }
  }

  void redirectToWifiScreen(BuildContext context) {
    isManual = true;
    showDeviceAddServerDialog(context);
  }
}
