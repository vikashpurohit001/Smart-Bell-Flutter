import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/util/CommonUtil.dart';

class MQTTManager {
  String topic;
  String deviceName;
  void Function(String) onMessage;

  MQTTManager(this.deviceName, this.topic, this.onMessage);

  MqttServerClient client = MqttServerClient.withPort(
      'a3n2130neve4if-ats.iot.eu-central-1.amazonaws.com', 'abc', 8883);

  Future<bool> connect() async {
    String username = await CommonUtil.getCurrentLoggedInUsername();
    client.logging(on: true);
    client.autoReconnect = true;
    client.secure = true;
    client.keepAlivePeriod = 1800000;
    client.setProtocolV311();

    final context = SecurityContext.defaultContext;
    WidgetsFlutterBinding.ensureInitialized();

    ByteData rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
    Map<String, String> credentials = await checkOrGenerate(deviceName);

    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(
        Uint8List.fromList(credentials['certificate'].codeUnits));
    context
        .usePrivateKeyBytes(Uint8List.fromList(credentials['key'].codeUnits));

    final connMess = MqttConnectMessage()
        .withClientIdentifier('esp32')
        .startClean()
        .withWillQos(MqttQos.exactlyOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    client.securityContext = context;
    await client.connect();

    String topicName = '${username}_${deviceName}';

    client.subscribe(topicName, MqttQos.atMostOnce);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      print('Listning on Topic $topicName');
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print(payload);
      onMessage(payload);
    });

    return true;
  }

  void publish(Map<String, dynamic> message) async {
    String username = await CommonUtil.getCurrentLoggedInUsername();
    String topicName = '${username}_${deviceName}';
    print(topicName);
    final builder = MqttClientPayloadBuilder();
    Map<String, dynamic> json = {
      'Device_Name': '${username}_${deviceName}_App',
      'Data': message
    };
    builder.addString(jsonEncode(json));
    client.publishMessage(topicName, MqttQos.atLeastOnce, builder.payload);
  }

  Future<Map<String, String>> checkOrGenerate(name) async {
    try {
      String key = await CommonUtil.readKey(deviceName);
      String certificate = await CommonUtil.readCertificate(deviceName);
      return {'key': key, 'certificate': certificate};
    } catch (e) {
      await RestServerApi.getCredentials(deviceName);
      String key = await CommonUtil.readKey(deviceName);
      String certificate = await CommonUtil.readCertificate(deviceName);
      return {'key': key, 'certificate': certificate};
    }
  }
}
