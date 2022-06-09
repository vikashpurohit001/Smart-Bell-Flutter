import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;

  OtpVerifyPage({
    this.email,
    Key key,
  }) : super(key: key);

  @override
  _OtpVerifyPageState createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends BaseState<OtpVerifyPage> {
  final TextEditingController otpTextController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _validate() async {
    if (otpTextController.text.isEmpty) {
      showSnackBar(
        'OTP cannot be blank',
        isError: true,
      );
    } else {
      RestServerApi.verifyEmail(widget.email, otpTextController.text)
          .then((response) {
        if (response['status'] == true) {
          CommonUtil.showOkDialog(
              context: context,
              message: response['message'],
              onClick: () {
                Navigators.pushAndRemoveUntil(context, LoginPage());
              });
        } else {
          showSnackBar(response['message'], isError: true);
        }
      });
    }
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
        'An email has been sent to yout email address',
        style: TextStyles.white14Normal,
      ),
    );
    Widget signInMessaage = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Verify your Email Address',
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
              'Verify',
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
                              OtpTextField(
                                controller: otpTextController,
                                label: 'OTP',
                                maxLength: configuredMaxLength,
                              ),
                              SizedBox(height: 2.h),
                              AppElevatedButtons('Verify',
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
