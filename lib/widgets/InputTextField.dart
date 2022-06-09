import 'package:smart_bell/utilities/Borders.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmailTextField extends StatefulWidget {
  TextEditingController controller;
  bool isValidate;
  String hint, label;
  Key shakeKey;

  EmailTextField(
      {Key key,
      this.controller,
      this.isValidate,
      this.hint,
      this.label,
      this.shakeKey})
      : super(key: key);

  @override
  _EmailTextFieldState createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          widget.isValidate = true;
        });
      },
      onSubmitted: (value) {
        setState(() {
          widget.isValidate = false;
        });
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        errorText:
            widget.isValidate ? null : widget.controller.emailErrorText(),
        errorMaxLines: 3,
        labelStyle: TextStyles.editTextLabelStyle(context),
        hintStyle: TextStyles.editTextHintStyle(),
        enabledBorder: Borders.enabledBorder(),
        focusedBorder: Borders.focusesBorder(context),
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(1.h, 2.h, 1.h, 1.h),
        errorStyle: TextStyles().errorTextStyle,
      ),
      cursorColor: Theme.of(context).primaryColor,
      style: TextStyles.editTextValueStyle(),
    );
  }
}

class InputTextField extends StatefulWidget {
  TextEditingController controller;
  bool isValidate;
  String hint, label;
  Widget prefixIcon, suffixIcon;
  bool enabled;
  String errorMessage;

  InputTextField(
      {Key key,
      this.controller,
      this.isValidate = true,
      this.hint = "",
      this.label,
      this.enabled = true,
      this.errorMessage,
      this.prefixIcon,
      this.suffixIcon})
      : super(key: key);

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          widget.isValidate = true;
        });
      },
      onSubmitted: (value) {
        setState(() {
          widget.isValidate = false;
        });
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        prefixIcon: widget.prefixIcon != null ? widget.prefixIcon : null,
        suffixIcon: widget.suffixIcon != null ? widget.suffixIcon : null,
        errorText: widget.errorMessage != null
            ? widget.errorMessage
            : widget.isValidate
                ? null
                : widget.controller.nameErrorText(),
        errorMaxLines: 3,
        labelStyle: TextStyles.editTextLabelStyle(context),
        hintStyle: TextStyles.editTextHintStyle(),
        enabledBorder: Borders.enabledBorder(),
        focusedBorder: Borders.focusesBorder(context),
        border: Borders.focusesBorder(context),
        enabled: widget.enabled,
        isDense: true,
        errorStyle: TextStyles().errorTextStyle,
        contentPadding: EdgeInsets.fromLTRB(1.h, 2.h, 1.h, 1.h),
      ),
      cursorColor: Theme.of(context).primaryColor,
      style: TextStyles.editTextValueStyle(),
    );
  }
}

class OtpTextField extends StatefulWidget {
  TextEditingController controller;
  bool isValidate;
  String hint, label;
  Widget prefixIcon, suffixIcon;
  bool enabled;
  String errorMessage;
  int maxLength;

  OtpTextField(
      {Key key,
      this.controller,
      this.label,
      this.enabled = true,
      this.prefixIcon,
      this.suffixIcon,
      this.maxLength})
      : super(key: key);

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: widget.maxLength,
      controller: widget.controller,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          widget.isValidate = true;
        });
      },
      onSubmitted: (value) {
        setState(() {
          widget.isValidate = false;
        });
      },
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.prefixIcon != null ? widget.prefixIcon : null,
        suffixIcon: widget.suffixIcon != null ? widget.suffixIcon : null,
        errorMaxLines: 3,
        labelStyle: TextStyles.editTextLabelStyle(context),
        hintStyle: TextStyles.editTextHintStyle(),
        enabledBorder: Borders.enabledBorder(),
        focusedBorder: Borders.focusesBorder(context),
        border: Borders.focusesBorder(context),
        enabled: widget.enabled,
        isDense: true,
        errorStyle: TextStyles().errorTextStyle,
        contentPadding: EdgeInsets.fromLTRB(1.h, 2.h, 1.h, 1.h),
      ),
      cursorColor: Theme.of(context).primaryColor,
      style: TextStyles.editTextValueStyle(),
    );
  }
}
