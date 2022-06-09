import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_bell/AppTourScreen.dart';
import 'package:smart_bell/dao/UserInfoData.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/AccountScreen.dart';
import 'package:smart_bell/screen/ChangePassword.dart';
import 'package:smart_bell/screen/ChangeWifiSettings.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AddSessionWidgets.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/widgets/AppStackView.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends BaseState<ProfileScreen> {
  UserInfoData infoData;
  String name = '', email = '';
  String version = '1.0.0';

  @override
  void initState() {
    getAppVersion();
    // getUserInfo();
    getInfoFromSession();
    super.initState();
  }

  getAppVersion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      print(packageInfo.buildNumber);
    });
  }

  getInfoFromSession() async {
    Map<String, String> user = await CommonUtil.getCurrentUser();
    setState(() {
      name = '${user['given_name']} ${user['family_name']}';
      email = '${user['email']}';
    });
  }

  getUserInfo() {
    RestServerApi().getUserInfo(context).then((value) {
      if (value != null) {
        if (value is UserInfoData) {
          infoData = value;
          setState(() {});
        }
      } else {
        showSnackBar("Can't fetch User Info. Please try again.", isError: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = infoData != null
        ? ("${infoData.firstName} ${infoData.lastName}")
        : this.name;
    return Container(
      child: Column(
        children: [
          Flexible(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/profile_bg.png"),
                        fit: BoxFit.cover)),
                child: AppStackView(child: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 4.h,
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 4.h,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text('$name', style: TextStyles.white16Normal),
                        Text('${infoData != null ? infoData.email : email}',
                            style: TextStyles.white16Normal),
                      ],
                    ),
                  ),
                ]),
              )),
          Flexible(
              flex: 7,
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: ListView(
                  children: [
                    ListWidget(
                      title: 'Account',
                      icon: Icons.person_outline,
                      onTap: () {
                        Navigators.push(
                            context,
                            AccountScreen(
                              infoData: infoData,
                            ));
                      },
                    ),
                    LineDivider(),
                    ListWidget(
                      title: 'Change Password',
                      icon: Icons.lock_outline_rounded,
                      onTap: () {
                        Navigators.push(context, ChangePassword());
                      },
                    ),
                    LineDivider(),
                    ListWidget(
                      title: 'Wifi Settings',
                      icon: Icons.wifi_sharp,
                      onTap: () {
                        Navigators.push(context, DeviceListToChangeWifi());
                      },
                    ),
                    LineDivider(),
                    ListWidget(
                      title: 'App Tour',
                      icon: Icons.play_circle_fill,
                      onTap: () {
                        Navigators.push(context, AppTourScreen());
                      },
                    ),
                    LineDivider(),
                    ListWidget(
                      title: 'Version',
                      value: version,
                      icon: Icons.mobile_friendly,
                      onTap: () {},
                    ),
                    LineDivider(),
                    ListWidget(
                      title: 'Logout',
                      icon: Icons.logout_rounded,
                      onTap: () {
                        CommonUtil.showYesNoDialog(
                            context: context,
                            message: 'Are you sure you want to logout?',
                            positiveClick: () {
                              Navigator.of(context).pop();
                              RestServerApi.logoutWithAmplify()
                                  .then((response) {
                                if (response['status'] == true) {
                                  Navigators.pushAndRemoveUntil(
                                      context, LoginPage());
                                } else {
                                  showSnackBar(response['message'],
                                      isError: true);
                                }
                              });
                            },
                            negativeClick: () {
                              Navigator.of(context).pop();
                            },
                            negativeText: 'No',
                            positiveText: 'Yes');
                      },
                    ),
                    LineDivider(),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

class ListWidget extends StatelessWidget {
  String title, value;
  IconData icon;
  Function onTap;

  ListWidget({this.title, this.icon, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 2.0.h, bottom: 2.h),
        child: Row(
          children: [
            SizedBox(
              width: 4.h,
            ),
            Icon(
              icon,
              color: Colors.black,
              size: 3.h,
            ),
            SizedBox(
              width: 3.h,
            ),
            Text(title, style: TextStyles.black16Normal),
            Expanded(child: Container()),
            if (value != null) Text(value, style: TextStyles.black16Normal),
            SizedBox(
              width: 4.h,
            ),
          ],
        ),
      ),
    );
  }
}
