import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Common Util is util class with many static methods
class CommonUtil {
  static var baseUrl = "iot.habilelabs.in:8081/api";

  ///
  /// Validate email string
  static bool isValidEmail(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(email);
  }

  static bool isStringNotEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  static bool isStringEmpty(String str) {
    return str == null || str.isEmpty;
  }

  static bool isHttpUrl(String url) {
    return url.toLowerCase().startsWith('http');
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  static dynamic getJsonVal(Map<String, dynamic> json, String key) {
    return json.containsKey(key) ? json[key] : null;
  }

  static void showOkDialog(
      {BuildContext context, String message, Function onClick}) {
    showDialog(
        context: context,
        builder: (context) {
          return Theme(
              data: ThemeData(dialogBackgroundColor: Colors.white),
              child: Builder(builder: (context) {
                return CupertinoAlertDialog(
                  content: Text(message),
                  actions: [TextButton(onPressed: onClick, child: Text('Ok'))],
                );
              }));
        });
  }

  static showYesNoDialog(
      {BuildContext context,
      String message,
      String positiveText,
      String negativeText,
      Function positiveClick,
      Function negativeClick}) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.light(),
          child: CupertinoAlertDialog(
            content: Text(
              message,
              style: TextStyles.black14Normal,
            ),
            actions: [
              CupertinoDialogAction(
                child: TextButton(
                  child: Text(
                    negativeText,
                    style: TextStyles.dialogNegativeButton(),
                  ),
                  onPressed: negativeClick,
                ),
              ),
              CupertinoDialogAction(
                child: TextButton(
                  child: Text(
                    positiveText,
                    style: TextStyles.dialogPositiveButton(context),
                  ),
                  onPressed: positiveClick,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static showSnackBar(context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        text,
        style: TextStyles().scaffoldTextSize,
      ),
      backgroundColor: Colors.red,
    ));
  }

  static askLocationWithDisclosure(BuildContext context, {Function onClick}) {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData.light(),
            child: CupertinoAlertDialog(
              title: Column(
                children: <Widget>[
                  Text(
                    "Use location",
                    style: TextStyles.theme22Bold(context),
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Icon(
                    Icons.location_pin,
                    color: TextStyles.THEME_COLOR,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
              content: new Text(
                "Smart Bell collects location data to enable Wifi even when the app is closed or not in use.",
                style: TextStyles.black16Normal,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    "Ok",
                    style: TextStyles.dialogPositiveButton(context),
                  ),
                  onPressed: onClick,
                ),
                CupertinoDialogAction(
                  child: Text(
                    "Cancel",
                    style: TextStyles.dialogNegativeButton(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  ////////////////////////////////////////////////////////////////////////////////////
  static Future<Map<String, String>> getCurrentUser() async {
    List<AuthUserAttribute> info = await Amplify.Auth.fetchUserAttributes();
    Map<String, String> user = {};
    info.forEach((element) {
      user[element.userAttributeKey.toString()] = element.value;
    });
    return user;
  }

  static String getUserNameFromEmail(String email) {
    return email.split('@')[0];
  }

  static Future<String> getCurrentLoggedInUsername() async {
    AuthUser info = await Amplify.Auth.getCurrentUser();
    return info.username.split('@')[0];
  }

  static Future<String> generateDeviceName(String name) async {
    String username = await getCurrentLoggedInUsername();
    return '${username}_${name}';
  }

  static Future<void> createCertificate(String data, String deviceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('/${directory.path}/$deviceName.crt');
    await file.writeAsString('$data');
  }

  static Future<void> createKey(String data, String deviceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$deviceName.pem.key');
    await file.writeAsString('$data');
  }

  static Future<String> readKey(String deviceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$deviceName.pem.key');
    final contents = await file.readAsString();
    return contents;
  }

  static Future<String> readCertificate(String deviceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$deviceName.crt');
    final contents = await file.readAsString();
    return contents;
  }

  static Future<String> extractDeviceName(String deviceName) async {
    String username = await getCurrentLoggedInUsername();
    String name = deviceName.split('${username}_')[1];
    name = name.split('.json')[0];
    return name;
  }
}
