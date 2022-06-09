
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/PasswordTextField.dart';
import 'package:flutter/material.dart';

class SetUpPassword extends StatefulWidget {
  @override
  _SetUpPasswordState createState() => _SetUpPasswordState();
}

class _SetUpPasswordState extends State<SetUpPassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isCPasswordHidden = true;

  bool isPasswordValidate = true;
  bool isCPasswordValidate = true;

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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            backgroundWidget,
            backWidget,
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // direction: Axis.vertical,
                children: [
                  Card(
                    elevation: 10,
                    margin: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 21, top: 21, right: 21),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // direction: Axis.vertical,
                        children: [
                          Text(
                            'Set Password',
                            style: TextStyles.titleLoginStyle(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          PasswordTextField(
                            passController: passwordController,
                            isPasswordHidden: _isPasswordHidden,
                            isPasswordValidate: isPasswordValidate,
                            label: 'Password',
                            hint: 'Password',
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          PasswordTextField(
                            passController: cPasswordController,
                            isPasswordHidden: _isCPasswordHidden,
                            isPasswordValidate: isCPasswordValidate,
                            label: 'Confirm Password',
                            hint: 'Confirm Password',
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
                                  "Save",
                                  style: TextStyles.buttonTextStyle(),
                                )),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 23,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setUpPassword(
      String password, String cPassword, BuildContext context) async {
    try {
      if (passwordController.passwordErrorText().isEmpty &&
          cPasswordController.confirmPasswordErrorText(password).isEmpty) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (pre) => false);
      } else {
        setState(() {
          isPasswordValidate = false;
          isCPasswordValidate = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
