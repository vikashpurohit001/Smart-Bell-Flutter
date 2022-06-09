import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/OtpVerifyScreen.dart';
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

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends BaseState<RegistrationPage> {
  final TextEditingController fName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController lName = TextEditingController();
  final TextEditingController pass = TextEditingController();

  bool _isPasswordHidden = true;

  bool isFNameValidate = true;
  bool isEmailValidate = true;
  bool isLNameValidate = true;
  bool isPasswordValidate = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // Old
  void signUp(String fname, String email, String lname, String password,
      BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    RestServerApi()
        .registerUser(context, fname, lname, email, null)
        .then((value) {
      if (value != null && value is Map) {
        //token expired
        return;
      }
      setState(() {
        _isLoading = false;
      });
      if (value is bool && value) {
        CommonUtil.showOkDialog(
            context: context,
            message:
                'User registered successfully. Check Mail to activate account.',
            onClick: () {
              Navigators.push(context, OtpVerifyPage());
            });
      } else {
        showSnackBar(
            (value is String)
                ? value.toString()
                : 'Error registering user. Please try again',
            isError: true);
      }
    }).catchError((onError) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar('Error registering user. Please try again', isError: true);
    });
  }

  // New With Amplify
  void _signUp(String fname, String email, String lname, String password,
      BuildContext context) async {
    if (isFormValid()) {
      setState(() {
        _isLoading = true;
      });
      RestServerApi.registerUserThroughAmplify(
              context, fname, lname, email, password)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == true) {
          CommonUtil.showOkDialog(
              context: context,
              message:
                  'User registered successfully. Check Mail to activate account.',
              onClick: () {
                Navigators.pushAndRemoveUntil(
                    context, OtpVerifyPage(email: email));
              });
        } else {
          showSnackBar(response['message'], isError: true);
        }
      });
    }
  }

  bool isFormValid() {
    if (fName.text.isEmpty) {
      showSnackBar('First Name cannot be blank', isError: true);
      // isFNameValidate = false;
      return false;
    } else if (lName.text.isEmpty) {
      showSnackBar('Last Name cannot be blank', isError: true);
      // isLNameValidate = false;
      return false;
    } else if (email.emailErrorText().isNotEmpty) {
      showSnackBar(email.emailErrorText(), isError: true);
      // isEmailValidate = false;
      return false;
    } else if (pass.passwordErrorText().isNotEmpty) {
      showSnackBar(pass.passwordErrorText(), isError: true);
      // isPasswordValidate = false;
      return false;
    }
    return true;
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
        'Hello there!',
        style: TextStyles.white14Normal,
      ),
    );
    Widget signInMessaage = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Sign up to Smart Bell.',
        style: TextStyles.white18Medium,
      ),
    );

    return Stack(
      children: [
        backgroundWidget,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 10.h,
            title: Text(
              'Register',
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
                        child: loginText,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 4.h),
                        child: signInMessaage,
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
                              InputTextField(
                                controller: fName,
                                isValidate: isFNameValidate,
                                hint: '',
                                label: 'First Name',
                              ),
                              SizedBox(height: 2.h),
                              InputTextField(
                                controller: lName,
                                isValidate: isLNameValidate,
                                hint: '',
                                label: 'Last Name',
                              ),
                              SizedBox(height: 2.h),
                              EmailTextField(
                                controller: email,
                                isValidate: isEmailValidate,
                                hint: '',
                                label: 'Email',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              PasswordTextField(
                                passController: pass,
                                isPasswordHidden: _isPasswordHidden,
                                isPasswordValidate: isPasswordValidate,
                                label: 'Password',
                                hint: '',
                              ),
                              SizedBox(height: 4.h),
                              AppElevatedButtons(
                                'Register',
                                onPressed: () {
                                  _signUp(fName.text, email.text, lName.text,
                                      pass.text, context);
                                },
                              ),
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
