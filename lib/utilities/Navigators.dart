import 'package:flutter/material.dart';

class Navigators {
  static Future<dynamic> pushReplacement(BuildContext context, Widget routeWidget) async {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (ctx) => routeWidget));
  }

  static Future<dynamic> push(BuildContext context, Widget routeWidget) async {
    return Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => routeWidget));
  }

  static Future<dynamic> pushAndRemoveUntil(BuildContext context, Widget routeWidget) async {
    return Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => routeWidget), (pre) => false);
  }
}
