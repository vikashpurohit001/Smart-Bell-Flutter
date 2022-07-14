import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/widgets/PasswordTextField.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({
    this.email,
    Key key,
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends BaseState<ResetPasswordScreen> {
  final TextEditingController otpTextController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isCPasswordHidden = true;

  bool isPasswordValidate = true;
  bool isCPasswordValidate = true;
  bool isCValidate = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _validate() async {
    if (passwordController.text.isEmpty) {
      showSnackBar(
        'Password cannot be blank',
        isError: true,
      );
      return;
    }
    if (cPasswordController.text.isEmpty) {
      showSnackBar(
        'Confirm Password cannot be blank',
        isError: true,
      );
      return;
    }
    if (!checkPasswordError()) return;

    if (otpTextController.text.isEmpty) {
      showSnackBar(
        'Confirmation Code cannot be blank',
        isError: true,
      );
    } else {
      RestServerApi.passwordResetVerifyWithAmplify(
              widget.email, passwordController.text, otpTextController.text)
          .then((response) {
        if (response['status'] == true) {
          // CommonUtil.showOkDialog(
          //     context: context,
          //     message: response['message'],
          //     onClick: () {
          //       Navigators.pushAndRemoveUntil(context, LoginPage());
          //     });
          showSnackBar(response['message']);
          Navigators.pushAndRemoveUntil(context, LoginPage());
        } else {
          showSnackBar(response['message'], isError: true);
        }
      });
    }
  }

  checkPasswordError() {
    bool val = true;

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
      isPasswordValidate = true;
      isCPasswordValidate = true;
      isCValidate = true;
    }

    setState(() {});
    return val;
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
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Colors.white,
        ),
        iconSize: 5.h,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    Widget loginText = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Enter the following Details',
        style: TextStyles.white14Normal,
      ),
    );
    Widget signInMessaage = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Reset your Password',
        style: TextStyles.white18Medium,
      ),
    );

    var configuredMaxLength = 6;
    return Stack(
      children: [
        backgroundWidget,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 10.h,
            title: Text(
              'Password',
            ),
            leading: backWidget,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: AppStackView(
              alignment: Alignment.center,
              isLoading: _isLoading,
              child: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // direction: Axis.vertical,
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 4.h),
                        child: signInMessaage,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 4.h),
                        child: loginText,
                      ),
                      Card(
                        elevation: 10,
                        margin: EdgeInsets.only(
                            top: 1.h, left: 4.h, right: 4.h, bottom: 5.h),
                        color: Colors.white,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 2.h, top: 2.h, right: 2.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // direction: Axis.vertical,
                            children: [
                              SizedBox(
                                height: 1.h,
                              ),
                              PasswordTextField(
                                passController: passwordController,
                                isPasswordHidden: _isPasswordHidden,
                                isPasswordValidate: isPasswordValidate,
                                isCValidate: isCValidate,
                                label: 'New Password',
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              PasswordTextField(
                                passController: cPasswordController,
                                isPasswordHidden: _isCPasswordHidden,
                                isPasswordValidate: isCPasswordValidate,
                                isCValidate: isCValidate,
                                label: 'Confirm Password',
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              OtpTextField(
                                controller: otpTextController,
                                label: 'Confirmation Code',
                                maxLength: configuredMaxLength,
                              ),
                              SizedBox(height: 1.h),
                              AppElevatedButtons('Continue',
                                  onPressed: _validate),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
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
}
