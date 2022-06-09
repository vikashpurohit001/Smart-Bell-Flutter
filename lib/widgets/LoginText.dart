import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/material.dart';

class LoginTitleText extends StatelessWidget {
  String title;

  LoginTitleText(this.title, {TextStyle style});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.titleLoginStyle(),
    );
  }
}

class LoginSubTitleText extends StatelessWidget {
  String title;

  LoginSubTitleText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.subtitleLoginStyle(),
    );
  }
}
