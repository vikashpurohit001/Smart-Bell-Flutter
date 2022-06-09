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

  AccountScreen({Key key, this.infoData}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends BaseState<AccountScreen> {
  UserInfoData infoData;
  TextEditingController editingController = TextEditingController();
  TextEditingController fName = TextEditingController();
  TextEditingController lName = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    infoData = widget.infoData;
    //change null
    if (infoData != null) {
      fName.text = infoData.firstName;
      lName.text = infoData.lastName;
      emailController.text = infoData.email;
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
                            child: AppElevatedButtons('Update',
                                onPressed: savePersonalDetails),
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
      String customerId = await SessionManager().getCustomerId();
      String userId = await SessionManager().getLoginUserId();
      String tenantId = await SessionManager().getTenantId();
      RestServerApi()
          .saveUser(context, fName.text, lName.text, emailController.text,
              userId, customerId, tenantId)
          .then((value) {
        if (value) {
          hideLoader();
          Navigator.of(context).pop();

          showSnackBar('Details has been successfully updated.');

          infoData.firstName = fName.text;

          infoData.lastName = lName.text;

          infoData.email = emailController.text;
        } else {
          Navigator.of(context).pop();
          showSnackBar('Unable to update details.', isError: true);
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
