import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/ResetPasswordScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:smart_bell/widgets/LoginText.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends BaseState<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();
  bool isEmailValidate = true;
  bool isLoading = false;

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
        'Oops!! Don\'t worry',
        style: TextStyles.white14Normal,
      ),
    );
    Widget signInMessaage = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Please enter your registered Email',
        style: TextStyles.white18Medium,
      ),
    );
    return Stack(children: [
      backgroundWidget,
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 10.h,
          title: LoginTitleText('Forgot Password'),
          leading: backWidget,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: AppStackView(
            alignment: Alignment.center,
            isLoading: isLoading,
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
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.h),
                      child: loginText,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.h),
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
                            EmailTextField(
                              controller: email,
                              isValidate: isEmailValidate,
                              hint: '',
                              label: 'Email',
                            ),
                            SizedBox(height: 4.h),
                            AppElevatedButtons('Continue', onPressed: () {
                              _forgotPassword(email.text, context);
                            }),
                            SizedBox(height: 4.h),
                          ],
                        ),
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

  void _forgotPassword(String email, BuildContext context) async {
    try {
      if (this.email.text.isValidEmail()) {
        setState(() {
          isLoading = true;
        });

        RestServerApi.passwordResetWithAmplify(this.email.text).then((value) {
          setState(() {
            isLoading = false;
          });
          if (value['status'] == false) {
            showSnackBar(
                (value is String)
                    ? value.toString()
                    : 'Please check Email Id or try again later.',
                isError: true);
          } else {
            showSnackBar(value['message']);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(email: email)));
          }
        });

        // RestServerApi().resetPassword(context, this.email.text).then((value) {
        //   if (value is bool && value) {
        //     showSnackBar('Password reset link was successfully sent!');

        //     this.email.text = "";
        //     isEmailValidate = true;
        //     setState(() {});
        //   } else {
        //     showSnackBar((value is String)
        //         ? value.toString()
        //         : 'Please check Email Id or try again later.',isError: true);
        //   }
        //   setState(() {
        //     isLoading = false;
        //   });
        // });
      } else {
        setState(() {
          isEmailValidate = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
