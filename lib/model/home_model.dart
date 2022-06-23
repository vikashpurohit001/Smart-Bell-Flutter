import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:smart_bell/dao/DeviceBell.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/model/single.dart';
import 'package:smart_bell/screen/AddSessionTime.dart';

import 'package:smart_bell/utilities/TextStyles.dart';

class HomeModel extends Model {
  SessionData sessionData;
  bool _isLoading = false;
  bool _isNoInternet = false;
  List<DeviceList> _deviceDataList = [];
  List<DeviceBell> _newDeviceList = [];
  List<MqttServerClient> _clientList = [];

  bool get isLoading => _isLoading;

  bool get isNoInternet => _isNoInternet;

  List<DeviceList> get deviceDataList => _deviceDataList;
  List<DeviceBell> get newDeviceList => _newDeviceList;

  List<MqttServerClient> get clientList => _clientList;

  void setIsLoading(isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  setIsNoInternet(isNoInternet) {
    _isNoInternet = isNoInternet;
    notifyListeners();
  }

  updateDeviceList(List<DeviceList> list) {
    _deviceDataList = list;
    notifyListeners();
  }

  updateNewDeviceList(List<DeviceBell> list) {
    _newDeviceList = list;
    notifyListeners();
  }

  addToNewDeviceList(String elementName) async {
    DeviceBell bell = DeviceBell(elementName);
    _newDeviceList.add(bell);
  }

  getDeviceList(context) async {
    setIsLoading(true);
    setIsNoInternet(false);
    String username = await CommonUtil.getCurrentLoggedInUsername();
    await _isInternetAvailable(context, onResult: (isInternet) {
      if (isInternet) {
        RestServerApi.getBellDeviceList(username).then((value) {
          if (value != null && value is List) {
            updateNewDeviceList(value);
          }
          setIsLoading(false);

          for (int i = 0; i < _deviceDataList.length; i++) {
            RestServerApi.getMiscDetail(
                    _deviceDataList.elementAt(i).name, 'last_check')
                .then((value) {
              print(value);
              DateTime time = DateFormat('dd-MM-yyyy,HH:mm').parse(value);
              Duration timeDifference = time.difference(DateTime.now());
              if (timeDifference.inMinutes.abs() >= 1) {
                _deviceDataList.elementAt(i).isActive = false;
              } else {
                _deviceDataList.elementAt(i).isActive = true;
              }
            });
          }
        }).catchError((error) {
          print("DeviceList Error $error");
          setIsNoInternet(true);
          setIsLoading(false);
        });
      } else {
        setIsNoInternet(true);
        setIsLoading(false);
      }
    });
  }

  Future<bool> _isInternetAvailable(context,
      {bool showPopUp = false, Function(bool) onResult}) async {
    final Ping ping = Ping('google.com', count: 5);
    bool result = false;
    bool isCalled = false;
    ping.stream.listen((event) {
      if (!isCalled) {
        ping.stop();
        isCalled = true;
        print(event);
        if (event.error == null) {
          result = true;
          onResult(true);
          return;
        } else {
          showInternetError(context, showPopUp: showPopUp);
          result = false;
          onResult(false);
          return;
        }
      }
    }).onDone(() {
      if (!isCalled) {
        isCalled = true;
        onResult(result);
      }
    });
  }

  Future<bool> isInternetAvailable(context,
      {bool showPopUp = false, Function(bool) onResult}) async {
    final Ping ping = Ping('google.com', count: 5);
    bool result = false;
    bool isCalled = false;
    ping.stream.listen((event) {
      if (!isCalled) {
        ping.stop();
        isCalled = true;
        print(event);
        if (event.error == null) {
          result = true;
          onResult(true);
          return;
        } else {
          showInternetError(context, showPopUp: showPopUp);
          result = false;
          onResult(false);
          return;
        }
      }
    }).onDone(() {
      if (!isCalled) {
        isCalled = true;
        onResult(result);
      }
    });
  }

  showInternetError(context, {bool showPopUp}) {
    if (showPopUp) {
      CommonUtil.showOkDialog(
          context: context,
          message: "Internet not available. Please connect and try again.",
          onClick: () => Navigator.of(context).pop());
    } else {
      showSnackBar(
          context, "Internet not available. Please connect and try again.",
          isError: true);
    }
  }

  showSnackBar(context, String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        text,
        style: TextStyles().scaffoldTextSize,
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}
