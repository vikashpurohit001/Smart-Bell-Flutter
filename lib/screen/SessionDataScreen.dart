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
import 'package:smart_bell/managers/MQTTManager.dart';
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
  String Username;

  SessionDataScreen({Key key, this.deviceData, this.Username})
      : super(key: key);

  @override
  _SessionDataScreenState createState() => _SessionDataScreenState();
}

class _SessionDataScreenState extends BaseState<SessionDataScreen> {
  List<SessionData> sessionList = [];
  bool isLoading = false;
  String Username;
  String lastSyncTime;
  String lastCheck;
  bool isInternetIssue = false;
  String wifiSSID = null;
  bool isActive;
  bool isPaused = false;
  DeviceAttributes deviceAttri;
  GlobalKey<SessionTimeListState> sessionKey =
      new GlobalKey<SessionTimeListState>();
  SessionDataController _sessionDataController = SessionDataController();
  MQTTManager MQTT;
  MqttServerClient client;

  @override
  void initState() {
    Username = widget.Username;
    MQTT = MQTTManager(
        widget.deviceData.name, widget.deviceData.name, processMQTTPayload);
    super.initState();
    getDataFromServer();
    getMQTTClientInstance();
  }

  getMQTTClientInstance() async {
    client = await MQTT.connect(context, true);
  }

  void processMQTTPayload(payload) {
    payload = jsonDecode(payload);
    Map<String, dynamic> data = Map.from(payload);
    if (data.containsKey('last_check')) {
      lastCheck = data['last_check'];
      setState(() {});
    } else if (data.containsKey('last_sync')) {
      lastSyncTime = data['last_sync'];
      setState(() {});
    } else {
      wifiSSID = data['wifi_name'];
      setState(() {});
    }
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }

  @override
  void dispose() {
    MQTT.client.disconnect();
    super.dispose();
  }

  getDataFromServer() {
    isLoading = true;
    isInternetIssue = false;
    setState(() {});
    getDeviceAttributes();
  }

  getDeviceAttributes() async {
    RestServerApi.getSessions(widget.deviceData.name).then((value) {
      setState(() {
        isLoading = false;
      });

      if (value is DeviceAttributes) {
        deviceAttri = value;
        isPaused = value.isPaused;
        sessionList = value.sessionList;
        sessionList.sort((a, b) =>
            a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));
      }

      // setState(() {});
    }).catchError((onError) {
      print('This is Error: $onError');
      setState(() {
        isInternetIssue = true;
        isLoading = false;
      });
      showSnackBar(
          "You might not connected to internet. Please check internet Connection.",
          isError: true);
    });
    lastSyncTime =
        await RestServerApi.getMiscDetail(widget.deviceData.name, 'last_sync');
    lastCheck =
        await RestServerApi.getMiscDetail(widget.deviceData.name, 'last_check');
    wifiSSID =
        await RestServerApi.getMiscDetail(widget.deviceData.name, 'wifi_name');
    setState(() {});
  }

  void addSession() async {
    SessionData data = await Navigators.push(
        context,
        AddSessionTime(
          dataList: this.sessionList,
        ));
    if (data != null) {
      List<SessionData> l = sessionList;
      l.add(data);
      l.sort((a, b) =>
          a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));
      setState(() {
        sessionList = l;
      });
      saveDataToServer();
      setState(() {
        isLoading = false;
      });
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
                        // InkWell(
                        //   onTap: () async {
                        //     // Navigators.push(context, NetworkInfo(wifiInfo:wifiSSID));
                        //   },
                        // child:
                        RichText(
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
                      // ),
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
                                onPressed: () {
                                  RestServerApi.getMiscDetail(
                                          widget.deviceData.name, 'last_sync')
                                      .then((response) {
                                    lastSyncTime = response;
                                    setState(() {});
                                  });
                                },
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
                                isPaused ? "Resume Bell" : "Pause Bell",
                                style: TextStyles.white14Normal,
                              ),
                              icon: Icon(
                                isPaused ? Icons.play_arrow : Icons.pause,
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
                                    isPaused: isPaused,
                                    isActive: widget.deviceData.isActive,
                                    lastCheck: lastCheck,
                                    onPause: onPause,
                                    onDelete: (result, index) {
                                      onDelete(result, index);
                                    },
                                    onSave: (result, sessionListResult) {
                                      // sessionList.clear();
                                      List<SessionData> newList = [];
                                      newList.addAll(sessionListResult);
                                      newList.sort((a, b) => a.time
                                          .getTimeInDateTime()
                                          .compareTo(
                                              b.time.getTimeInDateTime()));
                                      setState(() {
                                        sessionList = newList;
                                      });

                                      onSave(result);
                                    }),
                      )
                    ],
                  ),
                )),
    );
  }

  void onPause() {
    isPaused = !isPaused;
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
            "count": sessionData.bellCount.toInt(),
            "isSpecialBell": sessionData.isSpecialBell.toInt()
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

    // Map<String, dynamic> serverData =
    //     deviceAttri != null && deviceAttri.attributes != null
    //         ? deviceAttri.attributes
    //         : {"isPaused": isPaused};

    // serverData["isPaused"] = isPaused;

    // if (client.connectionStatus.state.name == 'connected') {
    //   MQTT.publish(serverData).then((value) {
    //     setState(() {});
    //     if (value == false) {
    //       showSnackBar("Error: try again after sometime", isError: true);
    //     }
    //   });
    // } else {
    //   showSnackBar("Error: Could not connect to Server", isError: true);
    // }

    // isLoading = true;
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
            "count": sessionData.bellCount.toInt(),
            "isSpecialBell": sessionData.isSpecialBell.toInt()
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
    // isLoading = true;
    // setState(() {});
    result['isPaused'] = isPaused;
    if (client.connectionStatus.state.name == 'connected') {
      MQTT.publish(result).then((value) {
        // isLoading = false;
        setState(() {});
        if (value == false) {
          showSnackBar("Error: try again after sometime", isError: true);
        }
      });
    } else {
      // isLoading = false;
      // setState(() {});
      showSnackBar("Error: Could Connect to server", isError: true);
    }
  }

  void onDelete(Map<String, dynamic> result, List<int> index) {
    for (int i = 0; i < index.length; i++) {
      // sessionList.removeAt(index.elementAt(i) - i);
    }

    result['isPaused'] = isPaused;
    deviceAttri.attributes = result;
    setState(() {});

    if (client.connectionStatus.state.name == 'connected') {
      MQTT.publish(result).then((value) {
        isLoading = false;
        setState(() {});
        if (value == false) {
          showSnackBar("Error: try again after sometime", isError: true);
        } else {
          CommonUtil.showOkDialog(
              context: context,
              message: "Session deleted successfully",
              onClick: () {
                Navigator.of(context).pop();
              });
        }
      });
    } else {
      isLoading = false;
      setState(() {});
      showSnackBar("Error: Could not Connect to server", isError: true);
    }
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
