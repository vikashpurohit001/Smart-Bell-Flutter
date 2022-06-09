import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Borders {
  static InputBorder enabledBorder() {
    return UnderlineInputBorder(
      borderRadius: new BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Color(0xff717171)),
    );
  }

  static InputBorder focusesBorder(context) {
    return UnderlineInputBorder(
        borderRadius: new BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor));
  }
}
