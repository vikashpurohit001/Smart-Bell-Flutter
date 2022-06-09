import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/ProgressIndicator.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  Dialog loaderDialog;

  // final Connectivity _connectivity = Connectivity();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  showLoaderDialog(BuildContext context) async {
    loaderDialog = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => new Dialog(
            backgroundColor: Colors.transparent,
            child: AppIndicator(),
            insetPadding: EdgeInsets.zero));
  }

  hideLoader() {
    Navigator.of(context).pop();
  }

  Future<bool> isInternetAvailable(
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
          showInternetError(showPopUp: showPopUp);
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

  showInternetError({bool showPopUp}) {
    if (showPopUp) {
      CommonUtil.showOkDialog(
          context: context,
          message: "Internet not available. Please connect and try again.",
          onClick: () => Navigator.of(context).pop());
    } else {
      showSnackBar("Internet not available. Please connect and try again.",
          isError: true);
    }
  }

  showSnackBar(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        text,
        style: TextStyles().scaffoldTextSize,
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}
