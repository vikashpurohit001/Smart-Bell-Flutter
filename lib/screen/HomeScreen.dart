import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:smart_bell/dao/DeviceBell.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/model/home_model.dart';
import 'package:smart_bell/model/main_model.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/QRCodeScreen.dart';
import 'package:smart_bell/screen/SetupDeviceScreen.dart';
import 'package:smart_bell/screen/WifiConnectErrorScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/LifeCycleEventHandler.dart';
import 'package:smart_bell/utilities/MethodChannelService.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:smart_bell/widgets/NoInternetScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:smart_bell/widgets/dashboard/home_widgets.dart';
import 'package:smart_bell/widgets/dashboard/navigation.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart' as WifiConfig;
import 'package:wifi_iot/wifi_iot.dart';
import 'package:sizer/sizer.dart';
import 'SessionDataScreen.dart';
import 'WifiScanScreen.dart';

class HomeScreen extends StatefulWidget {
  Function(List<GlobalKey>) onTargetAdded;

  HomeScreen({Key key, this.onTargetAdded}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  bool isManual;
  TextEditingController deviceTitleController = TextEditingController();
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey addDevice = GlobalKey();
  GlobalKey listTileKey = GlobalKey();
  GlobalKey _editKey = GlobalKey();
  bool isAppLaunch = false;

  @override
  void initState() {
    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(false);
    }

    getDeviceInfo();
    widget.onTargetAdded([addDevice, listTileKey]);
    eventHandlers();
    super.initState();
  }

  void eventHandlers() {
    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async => getDeviceInfo()));
  }

  HomeModel model;

  void getDeviceInfo() async {
    isAppLaunch = await SessionManager().isAppLaunch();
    Map<String, dynamic> deviceInfo =
        await SessionManager().getRecentDeviceInfo();
    if (deviceInfo != null) {
      Navigators.pushAndRemoveUntil(context, WifiConnectErrorScreen());
    } else {
      model = ScopedModel.of<MainModel>(context);
      getDeviceInformation();
    }
  }

  getDeviceInformation() async {
    model.getDeviceList(context);
  }

  @override
  void dispose() {
    try {
      if (model.clientList != null) {
        for (int i = 0; i < model.clientList.length; i++) {
          model.clientList.elementAt(i).unsubscribe("data_receive");
          model.clientList
              .elementAt(i)
              .unsubscribe("data_receive" + "/response/+");
          model.clientList.elementAt(i).autoReconnect = false;
          model.clientList.elementAt(i).disconnect();
        }
      }
    } on Exception catch (e) {
      print(e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return AppStackView(
        isLoading: model.isLoading,
        child: [
          model.isNoInternet && model.newDeviceList.isEmpty
              ? NoInternetScreen(onPressed: getDeviceInfo)
              : !model.isLoading && model.newDeviceList.isEmpty
                  ? SetUpDeviceScreen()
                  : deviceListWidget(model)
        ],
      );
    });
  }

  void redirectToSessionDataScreen(int index) {
    Navigators.push(context,
        SessionDataScreen(deviceData: model.newDeviceList.elementAt(index)));
  }

  Widget deviceListWidget(MainModel model) {
    Widget addDeviceImage = Image.asset(
      'assets/images/add_device.png',
      height: 6.h,
    );
    Widget addDeviceWidget = ShowCaseItemWidget(
      isAppLaunch: isAppLaunch,
      navKey: addDevice,
      description: "Click on Add Device to add new Device.",
      child: addDeviceImage,
    );

    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device List',
                  style: Theme.of(context).textTheme.headline1,
                ),
                InkWell(
                  onTap: () {
                    _showWifiDialog(context);
                  },
                  child: addDeviceWidget,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          Flexible(
              flex: 1,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                    child: DeviceDataWidget((isAppLaunch && index == 0),
                        model.newDeviceList.elementAt(index)),
                    onTap: () {
                      redirectToSessionDataScreen(index);
                    },
                  );
                },
                itemCount: model.newDeviceList.length,
              )),
        ],
      ),
    );
  }

  void deleteDevice(DeviceBell _data) async {
    showLoaderDialog(context);
    // RestServerApi().deleteDevice(context, _data.deviceId).then((value) {
    //   hideLoader();
    //   if (!(value is Map)) {
    //     this.model.deviceDataList.remove(_data);
    //     setState(() {});
    //     showSnackBar('Device deleted successfully.');
    //   } else {
    //     showSnackBar('Error deleting device. Please try again later.',
    //         isError: true);
    //   }
    // }).catchError((onError) {
    //   hideLoader();
    //   showSnackBar(
    //       'Error deleting device.${onError.toString()} Please try again. ',
    //       isError: true);
    // });
  }

  Future<dynamic> addDeviceToServer(context, deviceName) async {
    dynamic value = await RestServerApi.createDevice(deviceName);
    hideLoader();
    if (value["status"] == true) {
      return null;
    }
    return value;
  }

  editDeviceToServer(BuildContext context, title, DeviceBell _data) {
    // RestServerApi()
    //     .addDeviceToServer(context, title, id: _data.deviceId)
    //     .then((value) {
    //   if (value != null && value is Map && value.containsKey("token")) {
    //     return;
    //   }
    //   Navigator.pop(context);
    //   if (value is String) {
    //     CommonUtil.showOkDialog(
    //         context: context,
    //         message: value,
    //         onClick: () {
    //           Navigator.pop(context);
    //         });
    //   } else if (value is Map) {
    //     _data.name = title;
    //     setState(() {});
    //     CommonUtil.showOkDialog(
    //         context: context,
    //         message: 'Device name updated successfully.',
    //         onClick: () {
    //           Navigator.pop(context);
    //         });
    //   }
    // });
  }

  void editDeviceName(DeviceBell _data) {
    showEditDialog(
        context: context,
        title: 'Rename',
        hint: 'Name',
        value: _data.name,
        positiveButton: 'Save',
        negativeButton: 'Cancel',
        onPositiveButtonPress: (title) async {
          await isInternetAvailable(
              showPopUp: true,
              onResult: (isInternet) {
                if (isInternet) {
                  editDeviceToServer(context, title, _data);
                }
              });
        });
  }

  deleteDeviceDialog(DeviceBell _data) {
    CommonUtil.showYesNoDialog(
        context: context,
        message: "Are you sure you want to delete device?",
        positiveText: "Yes",
        positiveClick: () {
          Navigator.of(context).pop();
          deleteDevice(_data);
        },
        negativeText: "No",
        negativeClick: () {
          Navigator.of(context).pop();
        });
  }

  Widget DeviceDataWidget(bool isShowCase, DeviceBell _data) {
    SwipeAction deleteWidget = swipeDelete(onTap: () {
      deleteDeviceDialog(_data);
    });

    Widget bellIcon =
        BellIcon(isActive: _data.isActive, isPaused: _data.isPaused);

    Widget deviceName = DeviceName(context, _data);
    Widget editIconItem = IconWidget(context, onPressed: () {
      editDeviceName(_data);
    }, data: _data);
    Widget editIcon = isShowCase
        ? EditIconShowCase(context, key: _editKey, child: editIconItem)
        : editIconItem;
    Widget deviceWidget = Container(
      margin: EdgeInsets.only(top: 1.h),
      child: SwipeActionCell(
        key: ObjectKey(_data),
        backgroundColor: Colors.white,
        trailingActions: <SwipeAction>[deleteWidget],
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  bellIcon,
                  SizedBox(
                    width: 3.h,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        deviceName,
                        editIcon,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return isShowCase
        ? Showcase(
            key: listTileKey,
            overlayPadding: EdgeInsets.all(10),
            description: 'Tap here to view Device Information.',
            onTargetClick: () {
              setState(() {
                ShowCaseWidget.of(context).startShowCase([_editKey]);
              });
            },
            disposeOnTap: true,
            child: deviceWidget)
        : deviceWidget;
  }

  Future<bool> isWifiEnabled() async {
    var connectivityResult;
    if (Platform.isAndroid) {
      connectivityResult = await WifiConfig.WifiConfiguration().isWifiEnabled();
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
                            if (Platform.isAndroid) {
                              WiFiForIoTPlugin.forceWifiUsage(true);
                            }
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

  showEditDialog(
      {BuildContext context,
      String title,
      String hint,
      String value,
      String positiveButton,
      String negativeButton,
      Function(String) onPositiveButtonPress}) {
    TextEditingController editingController = TextEditingController();
    editingController.text = value;
    showGeneralDialog(
      context: context,
      pageBuilder: (context, ani, secAni) {
        return Sizer(builder: (context, orien, deviceType) {
          return Theme(
            data: ThemeData.light(),
            child: CupertinoAlertDialog(
              title: Center(
                  child: Text(
                title,
                style: TextStyles().black18Normal,
              )),
              content: Container(
                width: double.infinity,
                child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Column(
                    children: [
                      InputTextField(
                        controller: editingController,
                        hint: hint,
                        label: hint,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    negativeButton,
                    style: TextStyles.dialogNegativeButton(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    positiveButton,
                    style: TextStyles.dialogPositiveButton(context),
                  ),
                  onPressed: () {
                    onPositiveButtonPress(editingController.text);
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  showDeviceAddServerDialog(BuildContext mContext) {
    bool isValidate = true;
    String errorMessage;
    deviceTitleController.clear();
    showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setBState) {
          return Theme(
            data: ThemeData.light(),
            child: CupertinoAlertDialog(
              title: TitleText('Add Device'),
              content: Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: InputTextField(
                    controller: deviceTitleController,
                    hint: 'Title',
                    label: 'Title',
                    errorMessage: errorMessage,
                    isValidate: isValidate),
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
                  onPressed: () async {
                    errorMessage = null;
                    String deviceName = deviceTitleController.text;
                    if (deviceName.isNotEmpty) {
                      await isInternetAvailable(
                          showPopUp: true,
                          onResult: (isInternet) async {
                            print("Internet Available");
                            if (isInternet) {
                              showLoaderDialog(context);
                              dynamic value =
                                  await addDeviceToServer(mContext, deviceName);
                              if (value != "") {
                                model.getDeviceList(context);
                                //putting "" in place of null
                                // if (value is String) {
                                // errorMessage = value;
                                // setBState(() {});
                                // } else if (value is Map) {
                                // Navigator.pop(context);
                                // Map<String, dynamic> result = value;
                                // String deviceToken = CommonUtil.getJsonVal(
                                //     result, 'deviceToken');
                                // String deviceId =
                                //     CommonUtil.getJsonVal(result, 'deviceId');
                                // if (deviceToken != "") {
                                //putting "" in place of null
                                // askManualOrAutoConnect(
                                //     deviceToken, deviceId, deviceName);
                                // } else {
                                // Delete
                                // RestServerApi()
                                //     .deleteDevice(context, deviceId);
                                // }
                                // }
                              }
                            } else {
                              setBState(() {
                                isValidate = false;
                              });
                            }
                          });
                    }
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  askManualOrAutoConnect(String deviceToken, deviceId, deviceName) async {
    SessionManager().saveRecentDeviceInfo(deviceId, deviceToken, deviceName);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    }
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
                    height: 1.h,
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
                  style: TextStyles.dialogPositiveButton(context),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  connectToWifi(deviceToken, deviceId, deviceName);
                  //qr code
                  //QRCodeScreen();
                },
              ),
              TextButton(
                child: Text(
                  'Manually',
                  style: TextStyles.dialogNeutralButton(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigators.pushAndRemoveUntil(
                      context, WifiScanScreen(deviceToken: deviceToken));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  connectToWifi(String deviceToken, deviceId, deviceName) async {
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

  void redirectToWifiScreen(BuildContext context) {
    isManual = true;
    showDeviceAddServerDialog(context);
  }
}
