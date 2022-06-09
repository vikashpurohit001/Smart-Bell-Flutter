import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ProgressIndicator.dart';
import 'package:smart_bell/utilities/Extensions.dart';

class AppStackView extends StatelessWidget {
  List<Widget> child;
  bool isLoading;
  bool isBackButton;
  AlignmentGeometry alignment;

  AppStackView(
      {Key key,
      this.child,
      this.isLoading = false,
      this.isBackButton = false,
      this.alignment = AlignmentDirectional.topStart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      child.add(AppIndicator());
    }

    if (isBackButton) {
      Widget backWidget = Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          iconSize: 24,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
      child.insert(0, backWidget);
    }
    Stack wi = Stack(
      alignment: alignment,
      children: child,
    );
    return wi;
  }
}
