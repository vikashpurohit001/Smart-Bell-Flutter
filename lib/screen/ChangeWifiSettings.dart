import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/dao/DeviceBell.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/ChangeWifiTour.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/NoInternetScreen.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'WifiScanScreen.dart';

class DeviceListToChangeWifi extends StatefulWidget {
  const DeviceListToChangeWifi({Key key}) : super(key: key);

  @override
  _DeviceListToChangeWifiState createState() => _DeviceListToChangeWifiState();
}

class _DeviceListToChangeWifiState extends BaseState<DeviceListToChangeWifi> {
  List<DeviceBell> _data = [];
  bool isLoading = true;
  bool isNoInternet = false;
  String Username = null;

  @override
  void initState() {
    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(false);
    }
    getDeviceInformation();
    super.initState();
  }

  getUsername() async {
    return await CommonUtil.getCurrentLoggedInUsername();
  }

  getDeviceInformation() async {
    setState(() {
      isLoading = true;
      isNoInternet = false;
    });
    await isInternetAvailable(onResult: (isInternet) async {
      if (isInternet) {
        String name = await CommonUtil.getCurrentLoggedInUsername();
        RestServerApi.getBellDeviceList(name).then((value) {
          isLoading = false;
          print(value);
          if (value != null && value is List) {
            _data = value;
          }
          setState(() {});
        }).catchError((error) {
          print(error);
          isNoInternet = true;
          isLoading = false;
          setState(() {});
        });
      } else {
        isNoInternet = true;
        isLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget backWidget = Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Color(0xff3E3E3E),
        ),
        iconSize: 4.h,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10.h,
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
        leadingWidth: 6.h,
        leading: backWidget,
        title: Text(
          'Manage Device Wifi',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      extendBodyBehindAppBar: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: AppStackView(
          isLoading: isLoading,
          child: [
            isNoInternet
                ? NoInternetScreen(onPressed: getDeviceInformation)
                : !isLoading && _data.isEmpty
                    ? Text('No connected Device found')
                    : deviceListWidget()
          ],
        ),
      ),
    );
  }

  Widget deviceListWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.h),
            child: Text(
              'Select device to change Wifi Authentication',
              style: TextStyles.black14Normal,
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          Flexible(
              flex: 1,
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  return InkWell(
                    child: DeviceDataWidget(_data.elementAt(index)),
                    onTap: () async {
                      showWifiColor(Username: Username);
                    },
                  );
                },
                itemCount: _data.length,
              )),
        ],
      ),
    );
  }

  showWifiColor({String Username}) {
    showDialog(
        context: context,
        builder: (builder) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(3.0.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                      child: Text(
                    'Is your Smart Bell is plugged in and showing Yellow light?',
                    style: TextStyles().black18Normal,
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(
                    height: 3.h,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.white),
                          child: Text(
                            'Yes',
                            style: TextStyles.theme14Normal,
                          ),
                          onPressed: () {
                            Navigators.push(
                                context, WifiScanScreen(Username: Username));
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5.h,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          child: Text(
                            'No',
                            style: TextStyles.white14Normal,
                          ),
                          onPressed: () {
                            Navigators.pushReplacement(
                                context, TurnOnResetButton());
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<String> getDeviceToken(String deviceId) async {
    dynamic value = await RestServerApi().getDeviceToken(context, deviceId);
    if (value is String) {
      return value;
    }
    return null;
  }

  Widget DeviceDataWidget(DeviceBell _data) {
    Widget bellIcon = Image.asset(
      'assets/images/app_icon.png',
      color: Theme.of(context).primaryColor,
      width: 4.h,
    );
    Widget deviceName = Flexible(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${_data.name}',
          style: TextStyles.black16Normal,
        ),
      ),
    );

    Widget wifiSSIDWidget = Flexible(
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _data.name != null ? _data.name : "",
              style: TextStyles().grey12Normal,
            )));

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.h),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
          child: Row(
            children: [
              bellIcon,
              SizedBox(
                width: 3.h,
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    deviceName,
                    if (_data.name != null) wifiSSIDWidget,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
