import 'dart:io';

import 'package:sizer/sizer.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/DeviceAddedScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:smart_bell/widgets/PasswordTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart' as WifiConfig;
import 'package:wifi_iot/wifi_iot.dart';

class AuthWifiScreen extends StatefulWidget {
  String wifiNetwork, deviceToken, deviceId;

  AuthWifiScreen({Key key, this.wifiNetwork, this.deviceToken, this.deviceId});

  @override
  _AuthWifiScreenState createState() => _AuthWifiScreenState();
}

class _AuthWifiScreenState extends BaseState<AuthWifiScreen> {
  TextEditingController _wifiController = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool _isPasswordHidden = true;

  bool isNameValidate = true;
  bool isPasswordValidate = true;
  bool isWifiNotConnected = false;
  bool isLoading = false;

  Map<String, String> recentDevice;

  @override
  void initState() {
    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(true);
    }
    if (widget.deviceId == null) {
      getRecentDeviceData();
    }
    _wifiController.text = widget.wifiNetwork;
    setState(() {});
    super.initState();
  }

  getRecentDeviceData() async {
    recentDevice = await SessionManager().getRecentDeviceInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget backWidget = Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Colors.black,
        ),
        iconSize: 3.h,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: AppStackView(
          isLoading: isLoading,
          isBackButton: false,
          child: [
            ListView(
              children: [
                Padding(
                  padding:  EdgeInsets.only( top: 2.h),
                  child: Row(
                    children: [
                      backWidget,
                      TitleText(
                        'Enter Wifi Password',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(right: 2.h, top: 1.h,left: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(
                        height: 10.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Image.asset(
                              'assets/images/wifi_router.png',
                              width: 15.h,
                              height: 15.h,
                            ),
                            Padding(
                              padding:  EdgeInsets.only(top: 3.h),
                              child: Image.asset(
                                'assets/images/wifi_icon.png',
                                width: 5.h,
                                height: 3.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      InputTextField(
                          controller: _wifiController,
                          isValidate: isNameValidate,
                          hint: 'Wi-Fi Name',
                          label: 'Wi-Fi Name',
                          prefixIcon: Icon(
                            Icons.wifi,
                            color: Theme.of(context).primaryColor,
                          )),
                      SizedBox(
                        height: 2.h,
                      ),
                      PasswordTextField(
                        passController: pass,
                        isPasswordValidate: isPasswordValidate,
                        isPasswordHidden: _isPasswordHidden,
                        label: 'Password',
                        hint: 'Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      AppElevatedButtons(
                        'Connect',
                        onPressed: () {
                          if (_wifiController.text.isNotEmpty &&
                              pass.text.isNotEmpty) connectToDevice(context);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  connectToDevice(context) {
    WiFiForIoTPlugin.forceWifiUsage(true);
    setState(() {
      isLoading = true;
    });
    String deviceId =
        recentDevice == null ? widget.deviceId : recentDevice['deviceId'];
    RestServerApi()
        .configureDevice(context, _wifiController.text, pass.text,
            widget.deviceToken, deviceId)
        .then((value) async {
      setState(() {
        isLoading = false;
      });
      Map<String, dynamic> wifiInfo = {
        "ssid": _wifiController.text.trim(),
        "deviceId": deviceId
      };
      SessionManager().saveWifiDetails(wifiInfo);
      if (value != null && value.isSuccess) {
        if (Platform.isAndroid) {
          WiFiForIoTPlugin.forceWifiUsage(false);
        }
        bool isNewConnection;
        if (widget.deviceId == null) {
          SessionManager().saveRecentDeviceInfo(null, null, null);
          isNewConnection = true;
        } else {
          isNewConnection = false;
        }
        Navigators.pushAndRemoveUntil(
            context,
            DeviceAddedScreen(
              deviceToken: widget.deviceToken,
              deviceId: deviceId,
              isNewConnection: isNewConnection,
            ));
      } else {
        manageErrorConnecting(value);
      }
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
      manageErrorConnecting(null);
    });
  }

  void manageErrorConnecting(value) async {
    bool isWifiEnabled =
        await WifiConfig.WifiConfiguration().isConnectedToWifi("Smart Bell");
    showSnackBar(
        isWifiEnabled
            ? value != null &&
                    value.message != null &&
                    value.message.toString().isNotEmpty
                ? value.message
                : "Error connecting to Bell. Please check 'SSID' and 'Password'."
            : "Smart Bell wifi is disconnected. Please reconnect wifi and try again.",
        isError: true);
    isPasswordValidate = false;
    isWifiNotConnected = true;
    setState(() {});
  }
}
