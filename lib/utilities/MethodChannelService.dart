import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class MethodChannelService {
  static const platform = const MethodChannel('habilelabs.io/ESP_bell');

  Future<bool> connectToWifi(String ssid, String password) async {
    var location = Location();
    bool result = false;
    if (!await location.serviceEnabled()) {
      result = await location.requestService();
    } else {
      result = true;
    }
    //String ssid = "Smart Bell";
    //String password = "password";
    if (result) {
      Map<String, String> arguments = {"ssid": ssid, "password": password};
      try {
        final dynamic result =
            await platform.invokeMethod('WifiConnect', arguments);
        return result;
      } on PlatformException catch (e) {
        print(e);
        return false;
      }
    }
  }

  Future<String> getWifiList() async {
    try {
      final dynamic result = await platform.invokeMethod('WifiList');
      return result;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }
}
