import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  String title;

  TitleText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.titleStyle(),
    );
  }
}

class ThemeSubtitleText extends StatelessWidget {
  String title;

  ThemeSubtitleText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.subtitleThemeStyle(context),
    );
  }
}

class SubtitleText extends StatelessWidget {
  String title;

  SubtitleText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.subtitleStyle(),
    );
  }
}

class ImageNoteText extends StatelessWidget {
  String title;

  ImageNoteText(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyles().black18Normal,
    );
  }
}
