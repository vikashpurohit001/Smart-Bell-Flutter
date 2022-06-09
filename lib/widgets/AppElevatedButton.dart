import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/material.dart';

class AppElevatedButtons extends StatelessWidget {
  String title;
  Function onPressed;

  AppElevatedButtons(this.title, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            title,
            style: TextStyles.buttonTextStyle(),
          )),
    );
  }
}
