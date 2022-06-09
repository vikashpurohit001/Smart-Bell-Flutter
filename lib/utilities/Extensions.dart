import 'package:smart_bell/widgets/ProgressIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  DateTime convertTimeToDateTime() {
    return DateFormat(DateFormat.HOUR24_MINUTE).parse(this);
  }
}

extension FormValidation on TextEditingController {
  bool isEmptyEmail() {
    return this.text.isEmpty ? true : false;
  }

  String emailErrorText() {
    if (this.isEmptyEmail()) {
      return "Email cannot be blank.";
    } else if (!this.text.isValidEmail()) {
      return "Invalid Email Id.";
    } else {
      return "";
    }
  }

  String passwordErrorText({bool isCP}) {
    String cpVal = "";
    if (isCP != null && isCP) {
      cpVal = "Confirm";
    }

    if (this.text.isEmpty) {
      return "$cpVal Password cannot be blank.";
    } else if (this.text.length < 6) {
      return "$cpVal Password should have atleast 6 characters.";
    } else {
      return "";
    }
  }

  String nameErrorText() {
    if (this.text.isEmpty) {
      return "Name cannot be blank.";
    } else {
      return "";
    }
  }

  String confirmPasswordErrorText(String value) {
    print(this.text);
    if (this.text.isEmpty) {
      return "Confirm Password cannot be blank.";
    } else if (this.text.length < 6) {
      return "Confirm Password should have atleast 6 characters.";
    } else if (!this.isMatch(value)) {
      return "Password and Confirm Password must be same.";
    } else {
      return "";
    }
  }

  bool isMatch(String value) {
    return (this.text == value);
  }
}

extension DateTimeFormat on DateTime {
  String getAmPmTime() {
    return DateFormat('h:mm a').format(this);
  }

  String getDateTime() {
    return DateFormat('MMM d, yyyy h:mm a').format(this);
  }
  String getTimeOnly() {
    return DateFormat('H:m').format(this);
  }

  String getDateOnly() {
    return DateFormat('MMM d, yyyy').format(this);
  }

  String getOnceDate() {
    String time = DateFormat(DateFormat.HOUR24_MINUTE_SECOND).format(this);
    DateTime currentDateTime = DateTime.now();
    String date = DateFormat('d-MM-yyyy').format(currentDateTime);
    String dateTime = "$date $time";
    DateTime todayDateTime = DateFormat('d-MM-yyyy HH:mm:ss').parse(dateTime);
    if (todayDateTime.isAfter(currentDateTime)) {
      return date;
    } else {
      currentDateTime = currentDateTime.add(Duration(days: 1));
      String date = DateFormat('d-MM-yyyy').format(currentDateTime);
      return date;
    }
  }

  getTimeInDateTime(){
    String date= this.getTimeOnly();
    return date.convertTimeToDateTime();
  }
}
