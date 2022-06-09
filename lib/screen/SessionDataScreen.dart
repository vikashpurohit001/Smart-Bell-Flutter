import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_bell/dao/DeviceAttribute.dart';
import 'package:smart_bell/dao/DeviceBell.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/NetworkInfo.dart';
import 'package:smart_bell/screen/SessionTimeList.dart';
import 'package:smart_bell/screen/SetupSessionTime.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/SessionDataController.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/NoInternetScreen.dart';
import 'package:smart_bell/widgets/ProgressIndicator.dart';
import 'package:sizer/sizer.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:smart_bell/model/single.dart';

import 'AddSessionTime.dart';
import 'DashboardScreen.dart';

class SessionDataScreen extends StatefulWidget {
  DeviceBell deviceData;
  String deviceToken;

  SessionDataScreen({Key key, this.deviceData, this.deviceToken})
      : super(key: key);

  @override
  _SessionDataScreenState createState() => _SessionDataScreenState();
}

class _SessionDataScreenState extends BaseState<SessionDataScreen> {
  List<SessionData> sessionList = [];
  bool isLoading = true;
  String deviceToken;
  String lastSyncTime;
  bool isInternetIssue = false;
  String wifiSSID = null;
  DeviceAttributes deviceAttri;
  GlobalKey<SessionTimeListState> sessionKey =
      new GlobalKey<SessionTimeListState>();
  SessionDataController _sessionDataController = SessionDataController();
  MqttServerClient client;

  @override
  void initState() {
    deviceToken = widget.deviceToken;

    getDataFromServer();
    super.initState();
  }

  // connection succeeded
  // void onConnected() {
  //   print('Connected');
  //   client.subscribe("data_receive", MqttQos.atLeastOnce);
  //   client.subscribe("data_receive" + "/response/+", MqttQos.atLeastOnce);
  //   String payload =
  //       '{"clientKeys":"last-check,last-sync", "sharedKeys":"isPaused"}';
  //   final builder1 = MqttClientPayloadBuilder();
  //   builder1.addString(payload);
  //   client.publishMessage('esp32_test', MqttQos.atLeastOnce, builder1.payload);
  // }

// unconnected
  // void onDisconnected() {
  //   print(' On Disconnected');
  // }

// subscribe to topic succeeded
  // void onSubscribed(String topic) {
  //   client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  //     final MqttPublishMessage message = c[0].payload;
  //     final payload =
  //         MqttPublishPayload.bytesToStringAsString(message.payload.message);
  //     Map result = json.decode(payload);
  //     print(result);

  //     if (result.containsKey("shared") &&
  //         result["shared"].containsKey('isPaused')) {
  //       widget.deviceData.isPaused = result['shared']['isPaused'];
  //       setState(() {});
  //     }
  //     if (result.containsKey("client") &&
  //         result["client"].containsKey('last-check')) {
  //       String lastCheck = result['client']['last-check'];
  //       if (lastCheck != null) {
  //         DateTime time = DateFormat('dd-MM-yyyy,HH:mm').parse(lastCheck);
  //         Duration timeDifference = time.difference(DateTime.now());
  //         if (timeDifference.inMinutes.abs() >= 1) {
  //           widget.deviceData.isActive = false;
  //         } else {
  //           widget.deviceData.isActive = true;
  //         }
  //         setState(() {});
  //       }
  //     }
  //     if (result.containsKey("client") &&
  //         result["client"].containsKey('last-sync')) {
  //       lastSyncTime = result['client']['last-sync'];
  //       setState(() {});
  //     }
  //   });
  // }

// subscribe to topic failed
  // void onSubscribeFail(String topic) {
  //   print('Failed to subscribe $topic');
  // }

// unsubscribe succeeded
  // void onUnsubscribed(String topic) {
  //   print('Unsubscribed topic: $topic');
  // }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  // Future<MqttServerClient> connectWithMqtt() async {
  //   client = MqttServerClient.withPort(
  //       'a3n2130neve4if-ats.iot.eu-central-1.amazonaws.com', 'esp32', 8883);
  //   client.logging(on: true);
  //   client.autoReconnect = true;

  //   client.onConnected = onConnected;
  //   client.onDisconnected = onDisconnected;
  //   client.onUnsubscribed = onUnsubscribed;
  //   client.onSubscribed = onSubscribed;
  //   client.onSubscribeFail = onSubscribeFail;
  //   client.pongCallback = pong;

  //   final connMessage = MqttConnectMessage().authenticateAs(deviceToken, '');
  //   client.connectionMessage = connMessage;
  //   try {
  //     await client.connect();
  //   } catch (e) {
  //     print('Exception: $e');
  //     client.disconnect();
  //   }
  //   return client;
  // }

  @override
  void dispose() {
    // if (client != null) {
    //   client.unsubscribe("data_receive");
    //   client.autoReconnect = false;
    //   client.disconnect();
    // }
    super.dispose();
  }

  getDataFromServer() {
    isLoading = true;
    isInternetIssue = false;
    setState(() {});
    if (deviceToken == null) {
      // RestServerApi()
      //     .getDeviceToken(context, widget.deviceData.deviceId)
      //     .then((value) {
      //   if (value is String) {
      //     deviceToken = value;
      //     getDeviceAttributes(value);
      //   }
      // }).catchError((onError) {
      //   setState(() {
      //     isInternetIssue = true;
      //     isLoading = false;
      //   });
      //   showSnackBar(
      //       "You might not connected to internet. Please check internet Connection.",
      //       isError: true);
      // });
    } else {
      // getDeviceAttributes(deviceToken);
    }
  }

  getDeviceAttributes(deviceToken) async {
    RestServerApi().getAttributesToDevice(context, deviceToken).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value != null && value is DeviceAttributes) {
        deviceAttri = value;
        //isPaused = value.isPaused;
        sessionList = value.sessionList;
        sessionList.sort((a, b) =>
            a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));

        if (value.clientAttri != null) {
          lastSyncTime = value.clientAttri['last-sync'];
          //String lastCheck = value.clientAttri['last-check'];
          wifiSSID = value.clientAttri['Wifi Name'];
          // if (lastCheck != null) {
          //   DateTime time = DateFormat('dd-MM-yyyy,HH:mm').parse(lastCheck);
          //   Duration timeDifference = time.difference(DateTime.now());
          //   print(timeDifference.inMinutes.abs());
          //   if (timeDifference.inMinutes.abs() >= 1) {
          //     isActive = false;
          //   } else {
          //     isActive = true;
          //   }
          // }
        }
        setState(() {});
      }
    }).catchError((onError) {
      print(onError);
      setState(() {
        isInternetIssue = true;
        isLoading = false;
      });
      showSnackBar(
          "You might not connected to internet. Please check internet Connection.",
          isError: true);
    });
  }

  void addSession() async {
    SessionData data = await Navigators.push(
        context,
        AddSessionTime(
          dataList: this.sessionList,
        ));
    if (data != null) {
      sessionList.add(data);
      sessionList.sort((a, b) =>
          a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));
      setState(() {});
      saveDataToServer();
    }
  }

  onBackPress() {
    if (_sessionDataController != null &&
        _sessionDataController.canDelete != null &&
        _sessionDataController.canDelete == true) {
      _sessionDataController.canDelete = false;
      setState(() {});
      sessionKey.currentState.CanDelete = false;
      sessionKey.currentState.setValueToController();

      sessionKey.currentState.setState(() {});
    } else {
      Navigators.pushAndRemoveUntil(context, DashboardScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeForm = "";
    if (lastSyncTime != null) {
      DateTime time = DateFormat('d-M-yyyy,HH:mm').parse(lastSyncTime);
      timeForm = time.getDateTime();
    }

    Widget backWidget = Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Color(0xff3E3E3E),
        ),
        iconSize: 4.h,
        onPressed: onBackPress,
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        onBackPress();
        return false;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            toolbarHeight: 10.h,
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0,
            brightness: Brightness.light,
            leadingWidth: 6.h,
            leading: backWidget,
            title: Text(
              isLoading
                  ? ""
                  : sessionList == null || sessionList.isEmpty
                      ? 'Set up Session Time'
                      : 'Session Time',
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: [
              TextButton(
                onPressed: addSession,
                child: Icon(
                  Icons.add_box_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 5.h,
                ),
              )
            ],
          ),
          extendBodyBehindAppBar: false,
          body: isLoading == true
              ? AppIndicator()
              : SafeArea(
                  child: Column(
                    children: [
                      if (wifiSSID != null)
                        InkWell(
                          onTap: () async {
                            // Navigators.push(context, NetworkInfo(wifiInfo:wifiSSID));
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.wifi_sharp,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                    text: "  ${wifiSSID}",
                                    style: TextStyles.black14Normal),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (timeForm.isNotEmpty)
                              TextButton.icon(
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(0)),
                                    minimumSize:
                                        MaterialStateProperty.all(Size(0, 0))),
                                onPressed: () {},
                                label: Text(
                                  timeForm,
                                  style: TextStyles.theme14Normal,
                                ),
                                icon: Icon(
                                  Icons.sync,
                                  color: TextStyles.THEME_COLOR,
                                ),
                              ),
                            Spacer(),
                            TextButton.icon(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.all(1.h)),
                                  minimumSize:
                                      MaterialStateProperty.all(Size(0, 0)),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor)),
                              onPressed: onPause,
                              label: Text(
                                widget.deviceData.isPaused
                                    ? "Resume Bell"
                                    : "Pause Bell",
                                style: TextStyles.white14Normal,
                              ),
                              icon: Icon(
                                widget.deviceData.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                color: Colors.white,
                                size: 3.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: (isInternetIssue)
                            ? NoInternetScreen(onPressed: getDataFromServer)
                            : sessionList.isEmpty
                                ? SetupSessionTime(
                                    sessionList: sessionList,
                                    onAdd: (onData) {
                                      onAdd(onData);
                                    })
                                : SessionTimeList(
                                    key: sessionKey,
                                    controller: _sessionDataController,
                                    sessionList: sessionList,
                                    isPaused: widget.deviceData.isPaused,
                                    isActive: widget.deviceData.isActive,
                                    onPause: onPause,
                                    onDelete: (result, index) {
                                      onDelete(result, index);
                                    },
                                    onSave: (result, sessionListResult) {
                                      sessionList.clear();
                                      sessionList.addAll(sessionListResult);
                                      sessionList.sort((a, b) => a.time
                                          .getTimeInDateTime()
                                          .compareTo(
                                              b.time.getTimeInDateTime()));
                                      setState(() {});
                                      onSave(result);
                                    }),
                      )
                    ],
                  ),
                )),
    );
  }

  void onPause() {
    widget.deviceData.isPaused = !widget.deviceData.isPaused;
    Map<String, dynamic> serverData =
        deviceAttri != null && deviceAttri.attributes != null
            ? deviceAttri.attributes
            : {"isPaused": widget.deviceData.isPaused};
    serverData["isPaused"] = widget.deviceData.isPaused;
    isLoading = true;
    setState(() {});
    // RestServerApi()
    //     .addAttributesToDevice(context, widget.deviceData.deviceId, serverData)
    //     .then((value) {
    //   if (!(value is Map)) {
    //     isLoading = false;
    //     setState(() {});
    //   }
    //   CommonUtil.showOkDialog(
    //       context: context,
    //       message: widget.deviceData.isPaused
    //           ? "Device paused successfully"
    //           : "Device resumed successfully",
    //       onClick: () {
    //         Navigator.of(context).pop();
    //       });
    // }).catchError((onError) {
    //   isLoading = false;
    //   widget.deviceData.isPaused = !widget.deviceData.isPaused;
    //   setState(() {});
    //   CommonUtil.showOkDialog(
    //       context: context,
    //       message: widget.deviceData.isPaused
    //           ? "Error while pausing device"
    //           : "Error while resumed device",
    //       onClick: () {
    //         Navigator.of(context).pop();
    //       });
    // });
  }

  void saveDataToServer() {
    Map<String, dynamic> map = {};
    for (SessionData sessionData in sessionList) {
      if (sessionData != null) {
        if (sessionData.weekdays.isEmpty) {
          Map<String, dynamic> m1 = {};
          String onceDate = sessionData.time.getOnceDate();
          if (map.containsKey(onceDate)) {
            m1 = map[onceDate];
          }

          m1[sessionData.shift_name] = {
            "time": sessionData.time.getTimeOnly(),
            "count": sessionData.bellCount,
            "isSpecialBell": sessionData.isSpecialBell
          };

          sessionData.weekdays.add(onceDate);
          map[onceDate] = m1;
        } else {
          List<String> weekDayList = [];
          weekDayList.addAll(sessionData.weekdays);
          for (String data in sessionData.weekdays) {
            if (checkWeekDayIsDate(data) && sessionData.weekdays.length > 1) {
              map[data] = {};
              weekDayList.remove(data);
            } else {
              Map<String, dynamic> m1 =
                  map.containsKey(data) ? map[data] : null;
              if (m1 != null) {
                m1[sessionData.shift_name] = {
                  "time": sessionData.time.getTimeOnly(),
                  "count": sessionData.bellCount,
                  "isSpecialBell": sessionData.isSpecialBell
                };
                map[data] = m1;
              } else {
                map[data] = {
                  sessionData.shift_name: {
                    "time": sessionData.time.getTimeOnly(),
                    "count": sessionData.bellCount,
                    "isSpecialBell": sessionData.isSpecialBell
                  }
                };
              }
            }
          }
          sessionData.weekdays = weekDayList;
        }
      }
    }
    onSave(map);
  }

  bool checkWeekDayIsDate(String weekday) {
    return weekday != "Sunday" &&
        weekday != "Monday" &&
        weekday != "Tuesday" &&
        weekday != "Wednesday" &&
        weekday != "Thursday" &&
        weekday != "Friday" &&
        weekday != "Saturday";
  }

  void onSave(Map<String, dynamic> result) {
    isLoading = true;
    setState(() {});
    // RestServerApi()
    //     .addAttributesToDevice(context, widget.deviceData.deviceId, result)
    //     .then((value) {
    //   if (!(value is Map)) {
    //     isLoading = false;
    //     setState(() {});
    //     deviceAttri.attributes = result;
    //   }
    //   CommonUtil.showOkDialog(
    //       context: context,
    //       message: "Session saved successfully",
    //       onClick: () {
    //         Navigator.of(context).pop();
    //       });
    // }).catchError((onError) {
    //   isLoading = false;
    //   sessionList.elementAt(sessionList.length - 1).isSynced = false;
    //   setState(() {});
    //   CommonUtil.showOkDialog(
    //       context: context,
    //       message: "Error saving session data. Please try again.",
    //       onClick: () {
    //         Navigator.of(context).pop();
    //       });
    // });
  }

  void onDelete(Map<String, dynamic> result, List<int> index) {
    isLoading = true;
    setState(() {});
    // RestServerApi()
    //     .addAttributesToDevice(context, widget.deviceData.deviceId, result)
    //     .then((value) {
    //   isLoading = false;
    //   for (int i = 0; i < index.length; i++) {
    //     sessionList.removeAt(index.elementAt(i) - i);
    //   }

    //   deviceAttri.attributes = result;
    //   setState(() {});
    //   CommonUtil.showOkDialog(
    //       context: context,
    //       message: "Session deleted successfully",
    //       onClick: () {
    //         Navigator.of(context).pop();
    //       });
    // }).catchError((onError) {
    //   isLoading = false;
    //   setState(() {});
    //   CommonUtil.showOkDialog(
    //       context: context,
    //       message: "Error deleting session data. Please try again.",
    //       onClick: () {
    //         Navigator.of(context).pop();
    //       });
    // });
  }

  void onAdd(SessionData sessionData) {
    if (sessionData != null) {
      sessionList.add(sessionData);
      sessionList.sort((a, b) =>
          a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));
      // deviceAttri.attributes=
      // setState(() {});
      saveDataToServer();
    }
  }
}
