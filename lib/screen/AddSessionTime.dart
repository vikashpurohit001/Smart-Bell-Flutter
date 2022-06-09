import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:smart_bell/dao/Constants.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/model/single.dart';
import 'package:smart_bell/screen/AddWeekScreen.dart';
import 'package:smart_bell/ui/BaseState.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:smart_bell/widgets/AddSessionWidgets.dart';
import 'package:smart_bell/widgets/InputTextField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:smart_bell/widgets/my_number_picker.dart';
import 'package:sizer/sizer.dart';

SessionData sessionData;

class AddSessionTime extends StatefulWidget {
  SessionData data;
  List<SessionData> dataList;

  AddSessionTime({this.data, this.dataList});

  @override
  _AddSessionTimeState createState() => _AddSessionTimeState();
}

class _AddSessionTimeState extends BaseState<AddSessionTime> {
  final TextEditingController name = TextEditingController();

  bool isNameValidate = true;

  String deviceToken;
  Map<String, dynamic> map = {};
  Map<String, bool> repeatList = {
    "Once": true,
    "Daily": false,
    "Mon to Sat": false,
    "Custom": false
  };

  @override
  void initState() {
    if (widget.data == null) {
      sessionData = SessionData();
      sessionData.time = DateTime.now().add(Duration(minutes: 5));
      sessionData.bellCount = 1;
      sessionData.isNoti = true;
      sessionData.isSpecialBell = 0;
      sessionData.weekdays = [];
    } else {
      sessionData = widget.data;
      if (sessionData.isSpecialBell == null) {
        sessionData.isSpecialBell = 0;
      }
    }
    name.text = sessionData.shift_name;
    setState(() {});
    super.initState();
  }

  bool checkWeekDayIsDate(String weekday) {
    return weekday != "Sunday" &&
        weekday != "Monday" &&
        weekday != "Tuesday" &&
        weekday != "Wednesday" &&
        weekday != "Thursday" &&
        weekday != "Friday" &&
        weekday != "Saturday";
  }

  String manageRepeatList() {
    repeatList.forEach((key, value) => repeatList[key] = false);
    var dateContain =
        sessionData.weekdays.where((element) => checkWeekDayIsDate(element));
    String repeatText = Constants.KEY_ONCE;
    try {
      if (dateContain.isEmpty) {
        if (sessionData.weekdays.isEmpty) {
          repeatText = Constants.KEY_ONCE;
        } else {
          repeatText = Constants.KEY_CUSTOM;
          repeatList[Constants.KEY_ONCE] = false;
          bool checkDays;
          checkDays = sessionData.weekdays.contains(Constants.MONDAY);
          if (checkDays) {
            checkDays = sessionData.weekdays.contains(Constants.TUESDAY);
            if (checkDays) {
              checkDays = sessionData.weekdays.contains(Constants.WEDNESDAY);
              if (checkDays) {
                checkDays = sessionData.weekdays.contains(Constants.THURSDAY);
                if (checkDays) {
                  checkDays = sessionData.weekdays.contains(Constants.FRIDAY);
                  if (checkDays) {
                    checkDays =
                        sessionData.weekdays.contains(Constants.SATURDAY);
                    if (checkDays) {
                      checkDays =
                          sessionData.weekdays.contains(Constants.SUNDAY);
                      if (checkDays) {
                        repeatText = Constants.KEY_DAILY;
                        repeatList[Constants.KEY_DAILY] = true;
                      } else {
                        repeatText = Constants.KEY_MON_SAT;
                        repeatList[Constants.KEY_MON_SAT] = true;
                      }
                    }
                  }
                }
              }
            }
          }

          if (repeatText == Constants.KEY_CUSTOM) {
            repeatList[Constants.KEY_CUSTOM] = true;
            repeatText = sessionData.weekdays
                .toString()
                .substring(1, sessionData.weekdays.toString().length - 1);
          }
        }
      } else {
        if (sessionData.weekdays.length == 1) {
          repeatText = Constants.KEY_ONCE;
        } else {
          repeatList[Constants.KEY_ONCE] = false;
          List<String> weekDayData = [];
          weekDayData.addAll(sessionData.weekdays);
          weekDayData.remove(dateContain.toList()[0]);

          bool checkDays;
          checkDays = sessionData.weekdays.contains(Constants.MONDAY);
          if (checkDays) {
            checkDays = sessionData.weekdays.contains(Constants.TUESDAY);
            if (checkDays) {
              checkDays = sessionData.weekdays.contains(Constants.WEDNESDAY);
              if (checkDays) {
                checkDays = sessionData.weekdays.contains(Constants.THURSDAY);
                if (checkDays) {
                  checkDays = sessionData.weekdays.contains(Constants.FRIDAY);
                  if (checkDays) {
                    checkDays =
                        sessionData.weekdays.contains(Constants.SATURDAY);
                    if (checkDays) {
                      checkDays =
                          sessionData.weekdays.contains(Constants.SUNDAY);
                      repeatText = Constants.KEY_DAILY;
                      repeatList[Constants.KEY_DAILY] = true;
                    } else {
                      repeatText = Constants.KEY_MON_SAT;
                      repeatList[Constants.KEY_MON_SAT] = true;
                    }
                  }
                }
              }
            }
          }
          if (repeatText == Constants.KEY_CUSTOM) {
            repeatList[Constants.KEY_CUSTOM] = true;
            repeatText = weekDayData
                .toString()
                .substring(1, weekDayData.toString().length - 1);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return repeatText;
  }

  @override
  Widget build(BuildContext context) {
    Widget backWidget = Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_sharp,
          color: Color(0xff3E3E3E),
        ),
        iconSize: 4.h,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
    String repeatText = manageRepeatList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 10.h,
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
        leading: backWidget,
        title: Text(
          '${widget.data != null ? 'Edit' : 'Add'} Session Time',
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await isInternetAvailable(onResult: (isInternet) {
                print("Internet Add Method Called:: $isInternet");
                if (isInternet) {
                  _saveSessionData();
                }
              });
            },
            child: Text(
              'Save',
              style: TextStyles.theme18Bold,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.h, right: 2.h),
              child: InputTextField(
                controller: name,
                isValidate: isNameValidate,
                label: 'Session Name',
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 0,
              child: TimePickerTheme(
                data: TimePickerThemeData(
                    shape: Border.symmetric(
                        horizontal:
                            BorderSide(color: Color(0xff717171), width: 1)),
                    inputDecorationTheme: InputDecorationTheme(
                        border: UnderlineInputBorder(),
                        fillColor: Colors.black)),
                child: TimePickerSpinner(
                  is24HourMode: false,
                  time: sessionData.time,
                  normalTextStyle: TextStyles().grey22Bold60Opacity,
                  highlightedTextStyle: TextStyles.theme22Bold(context),
                  spacing: 3.h,
                  itemHeight: 7.h,
                  itemWidth: 8.h,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      sessionData.time = time;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SessionListForwardTile(
                      label: 'Repeat',
                      value: repeatText,
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        _showRepeatDialog(sessionData);
                      }),
                  LineDivider(),
                  SessionListForwardTile(
                      label: 'Bell Count',
                      value: sessionData.bellCount == 1
                          ? 'Once'
                          : sessionData.bellCount.toString(),
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        _showBellCountDialog(sessionData);
                      }),
                  LineDivider(),
                  SessionListSwitchTile(
                    label: 'Special Bell',
                    value: sessionData.isSpecialBell == 1,
                    onChanged: (val) {
                      FocusScope.of(context).unfocus();
                      sessionData.isSpecialBell = val ? 1 : 0;
                      setState(() {});
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _saveSessionData() {
    sessionData.shift_name = name.text;
    if (sessionData.shift_name.isEmpty) {
      isNameValidate = false;
      setState(() {});
    } else {
      if (widget.dataList != null) {
        Iterable<SessionData> iList = this
            .widget
            .dataList
            .where((element) => element.shift_name == sessionData.shift_name);
        if ((widget.data != null && iList.length > 1) ||
            (widget.data == null && iList.length > 0)) {
          CommonUtil.showOkDialog(
              context: context,
              message: "Session already exist",
              onClick: () {
                Navigator.of(context).pop();
              });
          return;
        } else {
          print("Session  List");
          Navigator.of(context).pop(sessionData);
          connectWithMqtt(sessionData);
          print(sessionData);
          //send data here

        }
      } else {
        Navigator.of(context).pop(sessionData);
      }
    }
  }

  _showRepeatDialog(SessionData sessionData) async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Card(
            elevation: 10,
            color: Color(0xffE1EBF4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2.h),
                  topRight: Radius.circular(2.h)),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: repeatList.keys.map((key) {
                  return ListTile(
                    tileColor:
                        repeatList[key] ? Colors.white : Colors.transparent,
                    title: new Text(key, style: TextStyles.black14Normal),
                    trailing: repeatList[key]
                        ? Icon(Icons.check,
                            size: 3.h, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () async {
                      repeatList.keys.forEach((keyData) {
                        repeatList[keyData] = false;
                      });
                      repeatList[key] = true;
                      if (key == Constants.KEY_ONCE) {
                        sessionData.weekdays = [];
                      } else if (key == Constants.KEY_DAILY) {
                        sessionData.weekdays = [
                          Constants.SUNDAY,
                          Constants.MONDAY,
                          Constants.TUESDAY,
                          Constants.WEDNESDAY,
                          Constants.THURSDAY,
                          Constants.FRIDAY,
                          Constants.SATURDAY
                        ];
                      } else if (key == Constants.KEY_MON_SAT) {
                        sessionData.weekdays = [
                          Constants.MONDAY,
                          Constants.TUESDAY,
                          Constants.WEDNESDAY,
                          Constants.THURSDAY,
                          Constants.FRIDAY,
                          Constants.SATURDAY
                        ];
                      } else {
                        List<String> selectedWeekdays = await Navigators.push(
                            context,
                            AddWeekScreen(
                              weekDays: sessionData.weekdays,
                            ));
                        sessionData.weekdays = selectedWeekdays;
                      }
                      setState(() {});
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  _showBellCountDialog(SessionData sessionData) async {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            return Card(
                elevation: 10,
                color: Color(0xffE1EBF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(1.h),
                      topRight: Radius.circular(1.h)),
                ),
                child: Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MyNumberPicker(
                            value: sessionData.bellCount,
                            minValue: 1,
                            maxValue: 10,
                            zeroPad: true,
                            haptics: true,
                            infiniteLoop: true,
                            itemWidth: double.maxFinite,
                            decoration: ShapeDecoration(
                                shape: Border.symmetric(
                                    horizontal: BorderSide(
                                        color:
                                            Color(0xff717171).withOpacity(0.6),
                                        width: 1))),
                            textStyle: GoogleFonts.getFont("Poppins",
                                textStyle: TextStyle(
                                    fontSize: 18.sp,
                                    color: Color(0xff3E3E3E).withOpacity(0.6))),
                            selectedTextStyle: GoogleFonts.getFont("Poppins",
                                textStyle: TextStyle(
                                    fontSize: 20.sp,
                                    color: Theme.of(context).primaryColor)),
                            itemHeight: 8.h,
                            onChanged: (value) {
                              state(() => sessionData.bellCount = value);
                              setState(() {});
                              // Navigator.of(context).pop();
                            }),
                      ],
                    )));
          });
        });
  }
}
