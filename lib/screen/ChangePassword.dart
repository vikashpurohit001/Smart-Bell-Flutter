import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/LoginText.dart';
import 'package:smart_bell/widgets/PasswordTextField.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends BaseState<ChangePassword> {
  TextEditingController oldPassController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  bool _isOldPasswordHidden = true;
  bool _isPasswordHidden = true;
  bool _isCPasswordHidden = true;

  bool isOldPasswordValidate = true;
  bool isPasswordValidate = true;
  bool isCPasswordValidate = true;
  bool isCValidate = true;

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
    return Stack(
      children: [
        backgroundWidget,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: LoginTitleText('Change Password'),
            leading: backWidget,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // direction: Axis.vertical,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Need more security! ',
                            style: TextStyles.white16Normal,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Proceed to change old one to new ',
                            style: TextStyles.white18Medium,
                          ),
                        ),
                      ),
                      Card(
                        elevation: 10,
                        margin:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 21, top: 21, right: 21),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // direction: Axis.vertical,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              PasswordTextField(
                                passController: oldPassController,
                                isPasswordHidden: _isOldPasswordHidden,
                                isPasswordValidate: isOldPasswordValidate,
                                label: 'Old Password',
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              PasswordTextField(
                                passController: passwordController,
                                isPasswordHidden: _isPasswordHidden,
                                isPasswordValidate: isPasswordValidate,
                                isCValidate: isCValidate,
                                label: 'New Password',
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              PasswordTextField(
                                passController: cPasswordController,
                                isPasswordHidden: _isCPasswordHidden,
                                isPasswordValidate: isCPasswordValidate,
                                isCValidate: isCValidate,
                                label: 'Confirm Password',
                              ),
                              SizedBox(height: 60),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      _setUpPassword(passwordController.text,
                                          cPasswordController.text, context);
                                    },
                                    child: Text(
                                      "Continue",
                                      style: TextStyles.buttonTextStyle(),
                                    )),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: RichText(
                            text: TextSpan(
                              text: 'NOTE: ',
                              style: TextStyles().red14Normal,
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Enter same password in both fields. Use an uppercase letter and a number for stronger password.',
                                  style: TextStyles.black14Normal,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  checkPasswordError() {
    bool val = true;
    if (!oldPassController.passwordErrorText().isEmpty) {
      isOldPasswordValidate = false;
      val = false;
    }
    if (!passwordController.passwordErrorText().isEmpty) {
      isPasswordValidate = false;
      val = false;
    }
    if (!cPasswordController
        .confirmPasswordErrorText(passwordController.text)
        .isEmpty) {
      isPasswordValidate = false;
      isCPasswordValidate = false;
      isCValidate = false;
      val = false;
    }

    if (val) {
      isOldPasswordValidate = true;
      isPasswordValidate = true;
      isCPasswordValidate = true;
      isCValidate = true;
    }

    setState(() {});
    return val;
  }

  void _setUpPassword(
      String password, String cPassword, BuildContext context) async {
    try {
      if (checkPasswordError()) {
        RestServerApi.updatePassword(
                oldPassController.text, passwordController.text)
            .then((value) {
          if (value['status'] == true) {
            Navigator.of(context).pop();
            showSnackBar('Password Updated Successfully');
          } else {
            showSnackBar(value['message'], isError: true);
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
