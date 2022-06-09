import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:smart_bell/amplifyconfiguration.dart';
import 'package:smart_bell/dao/LoginResponse.dart';
import 'package:smart_bell/dao/UserInfoData.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/MainPage.dart';
import 'package:smart_bell/screen/RegisterationPage.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AppElevatedButton.dart';
import 'package:smart_bell/widgets/AppStackView.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:smart_bell/widgets/LoginText.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/widgets/ShowCase.dart';

import '../widgets/PasswordTextField.dart';
import 'ForgotPasswordScreen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BaseState<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool _isPasswordHidden = true;

  bool isEmailValidate = true;
  bool isPasswordValidate = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugins(
          [AmplifyAuthCognito(), AmplifyAnalyticsPinpoint()]);

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException catch (e) {
    } on Exception catch (e) {}
  }

  checkSession() async {
    try {
      AuthSession session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        Navigators.push(context, ShowCase());
      }
    } catch (e) {}
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
          Navigator.canPop(context)
              ? Navigator.of(context).pop()
              : Navigators.pushAndRemoveUntil(context, MainPage());
        },
      ),
    );
    Widget loginText = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Welcome Back!',
        style: TextStyles.white14Normal,
      ),
    );
    Widget signInMessaage = Align(
      alignment: Alignment.topLeft,
      child: Text(
        'Sign in to your Smart Bell account',
        style: TextStyles.white18Medium,
      ),
    );
    return Stack(children: [
      backgroundWidget,
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 10.h,
          title: LoginTitleText('Login'),
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
                            SizedBox(
                              height: 1.h,
                            ),
                            EmailTextField(
                              controller: email,
                              isValidate: isEmailValidate,
                              hint: '',
                              label: 'Email',
                            ),
                            SizedBox(height: 2.h),
                            PasswordTextField(
                              passController: pass,
                              isPasswordHidden: _isPasswordHidden,
                              isPasswordValidate: isPasswordValidate,
                              label: 'Password',
                              hint: '',
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigators.push(
                                      context, ForgotPasswordScreen());
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyles.flatInfoButtonTextStyles(
                                      context),
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            AppElevatedButtons('Login', onPressed: () {
                              _Login(
                                  email.text.toLowerCase(), pass.text, context);
                            }),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Don’t have an account? ',
                        style: TextStyles().black12Normal,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Register now',
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                Navigators.push(context, RegistrationPage());
                              },
                            style: TextStyles.flatInfoButtonTextStyles(context),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    ]);
  }

  void _Login(String email, String password, BuildContext context) async {
    try {
      if (isLoginValid(this.email, this.pass)) {
        // if (await ProviderState().LoginUser(email, password)) {
        doLogin(context);
      } else {
        isEmailValidate = false;
        isPasswordValidate = false;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  bool isLoginValid(
      TextEditingController email, TextEditingController password) {
    return (email.emailErrorText().isEmpty &&
        password.passwordErrorText().isEmpty);
  }

  // Old
  _doLogin(BuildContext context) {
    setState(() {
      isLoading = true;
    });
    new RestServerApi()
        .login(context, email.text.toLowerCase(), pass.text)
        .then((AppLoginResponse result) {
      pass.clear();

      if (result.isSuccess) {
        RestServerApi().getUserInfo(context).then((value) {
          setState(() {
            isLoading = false;
          });
          if (value != null) {
            if (value is UserInfoData) {
              Navigators.push(context, ShowCase());
            } else {
              // Session Out
            }
          } else {
            showSnackBar("Can't fetch User Info. Please try again.",
                isError: true);
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackBar(result.message, isError: true);
      }
    }).catchError((onError) {
      print(onError);

      setState(() {
        isLoading = false;
      });
      showSnackBar("Login failed. Please try again", isError: true);
    });
  }

  // New with Amplify
  doLogin(BuildContext context) {
    setState(() {
      isLoading = true;
    });

    RestServerApi.loginWithAmplify(context, email.text.toLowerCase(), pass.text)
        .then((response) async {
      setState(() {
        isLoading = false;
      });
      if (response['status'] == true) {
        Navigators.pushReplacement(context, ShowCase());
        showSnackBar(response['message']);
      } else {
        showSnackBar(response['message'], isError: true);
      }
    });
  }
}
