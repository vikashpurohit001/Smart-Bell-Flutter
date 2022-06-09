import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/screen/AddSessionTime.dart';
// SingletonOne._privateConstructor();

// static final SingletonOne _instance = SingletonOne._privateConstructor();
final MqttServerClient client = MqttServerClient.withPort(
    'a3n2130neve4if-ats.iot.eu-central-1.amazonaws.com', 'abc', 8883);

Future<MqttServerClient> connectWithMqtt(SessionData) async {
  client.logging(on: true);
  client.autoReconnect = true;
  client.secure = true;
  client.keepAlivePeriod = 1800000;
  client.setProtocolV311();

  final context = SecurityContext.defaultContext;
  WidgetsFlutterBinding.ensureInitialized();

  ByteData rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
  ByteData deviceCert =
      await rootBundle.load('assets/certs/certificate.pem.crt');
  ByteData privateKey = await rootBundle.load('assets/certs/private.pem.key');

  context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
  context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
  context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

  final connMess = MqttConnectMessage()
      .withClientIdentifier('esp32')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.exactlyOnce);
  print('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;

  client.securityContext = context;
  // try {
  await client.connect();
  // } on NoConnectionException catch (e) {
  //   // Raised by the client when connection fails.
  //   print('EXAMPLE::client exception - $e');
  //   client.disconnect();
  //   exit(-1);
  // } on SocketException catch (e) {
  //   // Raised by the socket layer
  //   print('EXAMPLE::socket exception - $e');
  //   client.disconnect();
  //   exit(-1);
  // }
  client.onConnected = () {
    client.subscribe("esp32_send", MqttQos.atMostOnce);
    String payload = '{"topic_sync":"last-check", "device_pause":"isPaused"}';
    final builder1 = MqttClientPayloadBuilder();
    //builder1.(sessionData);
    final sessionData1 = sessionData.toString();
    builder1.addString(sessionData1);

    print(sessionData1);
    print('sessionData');
    print(SessionData);
    print('SessionData');
    client.publishMessage('esp32_test', MqttQos.atMostOnce, builder1.payload);
  };

  // client.onSubscribed = (String topic) {
  //   client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  //     final MqttPublishMessage message = c[0].payload;
  //     final payload =
  //         MqttPublishPayload.bytesToStringAsString(message.payload.message);
  //     Map result = json.decode(payload);
  //     print(result);

  //     //comment line start

  //     // if (result.containsKey('isPaused')) {
  //     //   _deviceDataList.elementAt(index).isPaused = result['isPaused'];
  //     // }
  //     // // if (result.containsKey("shared") &&
  //     // //     result["shared"].containsKey('isPaused')) {
  //     // //   _deviceDataList.elementAt(index).isPaused =
  //     // //       result['shared']['isPaused'];
  //     // // }
  //     // if (result.containsKey("client") &&
  //     //     result["client"].containsKey('last-check')) {
  //     //   String lastCheck = result['client']['last-check'];
  //     //   if (lastCheck != null) {
  //     //     DateTime time = DateFormat('d-M-yyyy,H:m').parse(lastCheck);
  //     //     Duration timeDifference = time.difference(DateTime.now());
  //     //     if (timeDifference.inMinutes.abs() >= 1) {
  //     //       _deviceDataList.elementAt(index).isActive = false;
  //     //     } else {
  //     //       _deviceDataList.elementAt(index).isActive = true;
  //     //     }
  //     //   }
  //     // }

  //     //comment lines end
  //     //notifyListeners();
  //   });
  // };
  return client;
}
