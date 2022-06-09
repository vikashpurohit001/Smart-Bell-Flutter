import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';

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

  getDeviceList(context) async {
    setIsLoading(true);
    setIsNoInternet(false);
    String username = await CommonUtil.getCurrentLoggedInUsername();
    await _isInternetAvailable(context, onResult: (isInternet) {
      if (isInternet) {
        RestServerApi.getBellDeviceList(username).then((value) {
          setIsLoading(false);

          if (value != null && value is List) {
            updateNewDeviceList(value);
          }

          // for (int i = 0; i < _deviceDataList.length; i++) {
          //   connectWithMqtt(sessionData);
          // RestServerApi()
          //     .getDeviceToken(context, _deviceDataList.elementAt(i).deviceId)
          //     .then((value) {
          //   _deviceDataList.elementAt(i).deviceToken = value;

          // });
          // }
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

  // Future<MqttServerClient> connectWithMqtt(int index, String deviceId) async {
  //   MqttServerClient client = MqttServerClient.withPort(
  //       'a3n2130neve4if-ats.iot.eu-central-1.amazonaws.com', 'esp32', 8883);
  //   client.logging(on: false);
  //   client.autoReconnect = true;
  //   client.secure = true;
  //   client.keepAlivePeriod = 20;
  //   client.setProtocolV311();

  //   final context = SecurityContext.defaultContext;

  //   WidgetsFlutterBinding.ensureInitialized();

  //   ByteData rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
  //   ByteData deviceCert =
  //       await rootBundle.load('assets/certs/certificate.pem.crt');
  //   ByteData privateKey = await rootBundle.load('assets/certs/private.pem.key');

  //   context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
  //   context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
  //   context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

  //   client.securityContext = context;

  //   // client.onConnected = () {
  //   //   client.subscribe("data_receive", MqttQos.atLeastOnce);
  //   //   client.subscribe("data_receive" + "/response/+", MqttQos.atLeastOnce);
  //   //   String payload = '{"topic_sync":"last-check", "device_pause":"isPaused"}';
  //   //   final builder1 = MqttClientPayloadBuilder();
  // builder1.addString(payload);
  // client.publishMessage(
  //     'topic_timetable_send', MqttQos.atLeastOnce, builder1.payload);
  //   // };

  //   //   client.onSubscribed = (String topic) {
  //   //     client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  //   //       final MqttPublishMessage message = c[0].payload;
  //   //       final payload =
  //   //           MqttPublishPayload.bytesToStringAsString(message.payload.message);
  //   //       Map result = json.decode(payload);
  //   //       print(result);

  //   // //comment line start

  //   //       // if (result.containsKey('isPaused')) {
  //   //       //   _deviceDataList.elementAt(index).isPaused = result['isPaused'];
  //   //       // }
  //   //       // // if (result.containsKey("shared") &&
  //   //       // //     result["shared"].containsKey('isPaused')) {
  //   //       // //   _deviceDataList.elementAt(index).isPaused =
  //   //       // //       result['shared']['isPaused'];
  //   //       // // }
  //   //       // if (result.containsKey("client") &&
  //   //       //     result["client"].containsKey('last-check')) {
  //   //       //   String lastCheck = result['client']['last-check'];
  //   //       //   if (lastCheck != null) {
  //   //       //     DateTime time = DateFormat('d-M-yyyy,H:m').parse(lastCheck);
  //   //       //     Duration timeDifference = time.difference(DateTime.now());
  //   //       //     if (timeDifference.inMinutes.abs() >= 1) {
  //   //       //       _deviceDataList.elementAt(index).isActive = false;
  //   //       //     } else {
  //   //       //       _deviceDataList.elementAt(index).isActive = true;
  //   //       //     }
  //   //       //   }
  //   //       // }

  //   //     //comment lines end
  //   //       notifyListeners();
  //   //     });
  //   //   };
  // }

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
