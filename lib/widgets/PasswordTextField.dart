import 'package:smart_bell/utilities/Borders.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PasswordTextField extends StatefulWidget {
  TextEditingController passController;
  bool isPasswordHidden;
  bool isPasswordValidate;
  bool isCValidate;
  String hint, label;
  Widget prefixIcon;
  String errorString;

  PasswordTextField(
      {Key key,
      this.passController,
      this.isPasswordValidate,
      this.isPasswordHidden,
      this.hint,
      this.isCValidate = true,
      this.errorString,
      this.prefixIcon,
      this.label})
      : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.passController,
      obscureText: widget.isPasswordHidden,
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          widget.isPasswordValidate = true;
        });
      },
      onSubmitted: (value) {
        setState(() {
          widget.isPasswordValidate = false;
        });
      },
      decoration: InputDecoration(
        errorText: widget.isPasswordValidate
            ? widget.isCValidate
                ? null
                : "Password and Confirm Password must be same."
            : widget.isCValidate
            ? widget.passController.passwordErrorText()
            : "Password and Confirm Password must be same.",
        errorMaxLines: 3,
        hintText: widget.hint,
        labelText: widget.label,
        prefixIcon: widget.prefixIcon != null ? widget.prefixIcon : null,
        suffixIcon: IconButton(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(right: 1.h),
            icon: Icon(
              !widget.isPasswordHidden
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Color(0xff717171),
            ),
            iconSize: 2.5.h,
            onPressed: () {
              widget.isPasswordHidden = !widget.isPasswordHidden;
              setState(() {});
            }),
        labelStyle: TextStyles.editTextLabelStyle(context),
        hintStyle: TextStyles.editTextHintStyle(),
        enabledBorder: Borders.enabledBorder(),
        focusedBorder: Borders.focusesBorder(context),
        errorStyle: TextStyles().errorTextStyle,
        isDense: true,
        // Added this
        contentPadding: EdgeInsets.fromLTRB(1.h, 2.h, 1.h, 1.h),
      ),
      cursorColor: Theme.of(context).primaryColor,
      style: TextStyles.editTextValueStyle(),
    );
  }
}
