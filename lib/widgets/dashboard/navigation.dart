import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:smart_bell/utilities/TextStyles.dart';

class NavText extends StatelessWidget {
  final String navText;

  NavText({Key key, this.navText = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      navText,
      style: TextStyles.black14Normal,
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData navIcon;
  final String navText;

  NavItem({Key key, this.navIcon, this.navText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          navIcon,
        ),
        NavText(navText: navText),
      ],
    );
  }
}

Widget MyShowCaseWidget({GlobalKey key, String description, Widget child}) =>
    Showcase(
      key: key,
      shapeBorder: CircleBorder(),
      overlayPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      description: description,
      child: child,
    );

class ShowCaseItemWidget extends StatelessWidget {
  final bool isAppLaunch;
  final GlobalKey navKey;
  final String description;
  final Widget child;

  ShowCaseItemWidget(
      {Key key, this.isAppLaunch, this.navKey, this.description, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isAppLaunch
        ? MyShowCaseWidget(key: navKey, description: description, child: child)
        : child;
  }
}
