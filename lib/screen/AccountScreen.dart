import 'package:smart_bell/dao/User.dart';
import 'package:smart_bell/dao/UserInfoData.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:smart_bell/widgets/LoginText.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  UserInfoData infoData;
  User userInfo;
  void Function(User) updateUserInfo;
  Map<String, String> userData;
  AccountScreen({Key key, this.userData, this.userInfo, this.updateUserInfo})
      : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends BaseState<AccountScreen> {
  UserInfoData infoData;
  User userInfo;
  Map<String, String> userData;
  TextEditingController editingController = TextEditingController();
  TextEditingController fName = TextEditingController();
  TextEditingController lName = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    userData = widget.userData;
    userInfo = widget.userInfo;
    //change null
    if (userInfo != null) {
      fName.text = userInfo.firstName;
      lName.text = userInfo.lastName;
      emailController.text = userInfo.email;
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget backgroundWidget = Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/bg_image.png"),
              fit: BoxFit.cover)),
    );
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
    return Stack(children: [
      backgroundWidget,
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: LoginTitleText('Account'),
          leading: backWidget,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: AppStackView(
            alignment: Alignment.center,
            child: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Hey! Here are your details.',
                          style: TextStyles.white16Normal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Update if something is wrong.',
                          style: TextStyles.white18Medium,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 10,
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // direction: Axis.vertical,
                        children: [
                          ListWidget(
                            title: 'First Name',
                            //value: "${infoData.firstName}",
                            textController: fName,
                          ),
                          ListWidget(
                            title: 'Last Name',
                            //value: "${infoData.lastName}",
                            textController: lName,
                          ),
                          ListWidget(
                            title: 'Email',
                            //  value: "${infoData.email}",
                            textController: emailController,
                            enabled: false,
                          ),
                          SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: AppElevatedButtons('Update', onPressed: () {
                              FocusScope.of(context).unfocus();
                              savePersonalDetails();
                            }),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  savePersonalDetails() async {
    if (fName.text.isNotEmpty &&
        lName.text.isNotEmpty &&
        emailController.text.isNotEmpty) {
      showLoaderDialog(context);
      RestServerApi.updateProfile(fName.text, lName.text).then((value) {
        if (value['status'] == true) {
          hideLoader();
          userInfo.firstName = fName.text;
          userInfo.lastName = lName.text;
          widget.updateUserInfo(userInfo);
          Navigator.of(context).pop();
          showSnackBar(value['message']);
        } else {
          Navigator.of(context).pop();
          showSnackBar(value['message'], isError: true);
        }
      });
    }
  }
}

class ListWidget extends StatelessWidget {
  String title;
  String value;
  bool enabled;
  TextEditingController textController;

  ListWidget(
      {this.title,
      this.value,
      @required this.textController,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 20, right: 20),
      child: InputTextField(
          controller: textController,
          label: title,
          isValidate: true,
          enabled: enabled,
          suffixIcon: enabled
              ? Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 16,
                )
              //null
              : null),
    );
  }
}
