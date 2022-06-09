import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/DashboardScreen.dart';
import 'package:smart_bell/screen/WifiScanScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/LifeCycleEventHandler.dart';
import 'package:smart_bell/utilities/MethodChannelService.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnectErrorScreen extends StatefulWidget {
  const WifiConnectErrorScreen({Key key}) : super(key: key);

  @override
  _WifiConnectErrorScreenState createState() => _WifiConnectErrorScreenState();
}

class _WifiConnectErrorScreenState extends BaseState<WifiConnectErrorScreen> {
  Map<String, dynamic> recentDevice;
  var subscription;
  bool isOpenSettings = false;

  @override
  void initState() {
    getRecentDeviceData();
    super.initState();
  }

  void eventHandlers() {
    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async => isWifiEnabled()));
  }

  connectToWifi() async {
    String deviceToken = recentDevice['deviceToken'];
    String ssid = "Smart Bell";
    String password = "password";
    print(ssid);
    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(true);
    }
    String connectedSSid = await WiFiForIoTPlugin.getSSID();
    if (connectedSSid == ssid) {
      Navigators.push(context, WifiScanScreen(deviceToken: deviceToken));
    } else {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      bool canAutoConnect = true;
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.model}');
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
                  context, WifiScanScreen(deviceToken: deviceToken));
            } else {
              hideLoader();
              Navigators.pushAndRemoveUntil(context, WifiConnectErrorScreen());
            }
          }).catchError((onError) {
            hideLoader();
            Navigators.pushAndRemoveUntil(
                context, WifiScanScreen(deviceToken: deviceToken));
          });
        });
      } else {
        showSnackBar(
            "Your Device is not compatible for auto connection. Try Manual Connection.");
      }
    }
  }

  Future<void> isWifiEnabled() async {
    if (Platform.isAndroid) {
      WifiConfiguration()
          .isWifiEnabled()
          .then((value) => connectToWifi())
          .catchError((onError) {
        connectToWifi();
      });
    } else {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi) {
        connectToWifi();
      }
    }
  }

  getRecentDeviceData() async {
    recentDevice = await SessionManager().getRecentDeviceInfo();
    setState(() {
      print(recentDevice);
    });
    if (recentDevice != null) {
      //isWifiEnabled();
      eventHandlers();
    }
  }

  @override
  dispose() {
    super.dispose();
    if (subscription != "") {
      //i have put "" in place of null
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
            ),
            LeftRightPaddingText(
              recentDevice != null
                  ? '\"${recentDevice['deviceName']}\" requires Wifi configuration'
                  : '',
              style: TextStyles().black24Normal,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            LeftRightPaddingText(
              'Configure Device to Smart Bell or delete the device.',
              style: TextStyles.subtitleThemeStyle(context),
            ),
            SizedBox(
              height: 30,
            ),
            LeftRightPaddingText(
                'Open the Wi-Fi Settings in your phone and select the network that begins with "Smart Bell". It may take some time to appear. ',
                style: TextStyles.subtitleLoginStyle()),
            SizedBox(
              height: 10,
            ),
            LeftRightPaddingText(
                'Come Back to screen when you are connected with network and stays connected for some moment even after it doesn\'t allow internet access',
                style: TextStyles.subtitleLoginStyle()),
            Expanded(
              child: Container(),
            ),
            Container(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text(
                        'Delete Device',
                        style: TextStyles.white16Normal,
                      ),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(10)),
                          shape: MaterialStateProperty.all(
                              ContinuousRectangleBorder())),
                      onPressed: () async {
                        showLoaderDialog(context);

                        dynamic value = await RestServerApi()
                            .deleteDevice(context, recentDevice['deviceId']);
                        if (!(value is Map)) {
                          SessionManager().saveRecentDeviceInfo("", "", "");
                          print("Hello");
                          hideLoader();
                          Navigators.pushAndRemoveUntil(
                              context, DashboardScreen());
                        } else {
                          showSnackBar(
                              'Error deleting device. Please try again.',
                              isError: true);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text(
                        'Configure Manually',
                        style: TextStyles.white16Normal,
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(10)),
                          shape: MaterialStateProperty.all(
                              ContinuousRectangleBorder())),
                      onPressed: () async {
                        isOpenSettings = true;
                        OpenSettings.openWIFISetting();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeftRightPaddingText extends StatelessWidget {
  String data;
  TextStyle style;
  TextAlign textAlign;

  LeftRightPaddingText(
    this.data, {
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          data,
          style: style,
          textAlign: textAlign,
        ));
  }
}
