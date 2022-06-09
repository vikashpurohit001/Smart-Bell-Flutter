import 'package:scoped_model/scoped_model.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:smart_bell/model/main_model.dart';
import 'package:smart_bell/screen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/widgets/dashboard/navigation.dart';

import 'ProfileScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends BaseState<DashboardScreen> {
  List<Widget> _widgetOptions = [];
  bool isAppLaunch = false;

  GlobalKey keyBottomNavigation1 = GlobalKey();
  GlobalKey keyBottomNavigation2 = GlobalKey();
  List<GlobalKey> showCaseWidgets = [];

  @override
  void initState() {
    showCaseWidgets = [keyBottomNavigation1, keyBottomNavigation2];
    showTutorial();
    super.initState();
  }

  void showTutorial() async {
    _widgetOptions = <Widget>[
      HomeScreen(
        onTargetAdded: (data) {
          showCaseWidgets.addAll(data);
        },
      ),
      ProfileScreen()
    ];
    isAppLaunch = await SessionManager().isAppLaunch();
    setState(() {});
    if (isAppLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ShowCaseWidget.of(context).startShowCase(showCaseWidgets);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget homeNav = NavItem(navIcon: Icons.home_rounded, navText: 'Home');
    Widget profileNav =
        NavItem(navIcon: Icons.person_rounded, navText: 'Profile');

    Widget homeIcon = ShowCaseItemWidget(
        isAppLaunch: isAppLaunch,
        navKey: keyBottomNavigation1,
        description: 'Click here to go to your Home',
        child: homeNav);

    Widget profileIcon = ShowCaseItemWidget(
        isAppLaunch: isAppLaunch,
        navKey: keyBottomNavigation2,
        description: 'Click here to go to your Profile',
        child: profileNav);

    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Theme.of(context).primaryColor, // status bar color
          brightness: Brightness.dark, // status bar brightness
        ),
        body: SafeArea(
          child: Center(
            child: _widgetOptions.elementAt(model.selectedIndex),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: homeIcon,
              label: '',
            ),
            BottomNavigationBarItem(
              icon: profileIcon,
              label: '',
            ),
          ],
          currentIndex: model.selectedIndex,
          unselectedItemColor: Color(0xffA5A5A5),
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: model.updateIndex,
          iconSize: 4.h,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      );
    });
  }
}
