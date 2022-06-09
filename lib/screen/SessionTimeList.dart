import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/screen/AddSessionTime.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:smart_bell/utilities/SessionDataController.dart';
import 'package:smart_bell/utilities/TextStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_bell/widgets/MyExpansionTile.dart';

class SessionTimeList extends StatefulWidget {
  List<SessionData> sessionList;
  bool isPaused, isActive;
  Function() onPause;
  final SessionDataController controller;
  Function(Map<String, dynamic>, List<SessionData>) onSave;
  Function(Map<String, dynamic>, List<int>) onDelete;

  SessionTimeList(
      {Key key,
      this.controller,
      this.sessionList,
      this.onSave,
      this.onPause,
      this.isActive,
      this.isPaused,
      this.onDelete})
      : super(key: key);

  @override
  SessionTimeListState createState() => SessionTimeListState();
}

class SessionTimeListState extends State<SessionTimeList> {
  List<SessionData> _data = [];
  bool CanDelete = false;

  @override
  void initState() {
    _data.addAll(widget.sessionList);
    super.initState();
  }

  setValueToController() {
    if (widget.controller != null) {
      widget.controller.canDelete = CanDelete;
    }
  }

  void deleteSessions() {
    CommonUtil.showYesNoDialog(
        context: context,
        message: 'Are you sure you want to delete this item?',
        positiveClick: () {
          Navigator.of(context).pop();
          List<List<String>> deletedWeekDays = [];
          List<int> itemDel = [];
          for (int i = 0; i < _data.length; i++) {
            if (_data.elementAt(i).isSelected) {
              deletedWeekDays.add(_data.elementAt(i).weekdays);
              itemDel.add(i);
            }
          }
          for (int i = 0; i < itemDel.length; i++) {
            _data.removeAt(itemDel.elementAt(i) - i);
          }
          deleteDataToServer(deletedWeekDays, itemDel);
          CanDelete = false;
          setValueToController();
          setState(() {});
        },
        negativeClick: () {
          Navigator.of(context).pop();
        },
        negativeText: 'No',
        positiveText: 'Yes');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: widget.isActive ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${_data.length} Session Active',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ],
              ),
              if (CanDelete)
                IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 2.h,
                  onPressed: () {
                    deleteSessions();
                  },
                  icon: Icon(
                    Icons.delete,
                    size: 3.h,
                    color: Colors.red,
                  ),
                )
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {

                return InkWell(
                  child: SessionDataWidget(_data.elementAt(index), index),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void saveDataToServer() {
    Map<String, dynamic> map = {};

    for (SessionData sessionData in _data) {
      if (sessionData.weekdays.isEmpty) {
        Map<String, dynamic> m1 = {};
        String onceDate = sessionData.time.getOnceDate();
        if (map.containsKey(onceDate)) {
          m1 = map[onceDate];
        }
        m1[sessionData.shift_name] = {
          "time": sessionData.time.getTimeOnly(),
          "count": sessionData.bellCount,
          "isSpecialBell": sessionData.isSpecialBell
        };

        sessionData.weekdays.add(onceDate);
        map[onceDate] = m1;
      } else {
        List<String> weekDayList = [];
        weekDayList.addAll(sessionData.weekdays);
        for (String data in sessionData.weekdays) {
          if (checkWeekDayIsDate(data) && sessionData.weekdays.length > 1) {
            map[data] = {};
            weekDayList.remove(data);
          } else {
            Map<String, dynamic> m1 = map.containsKey(data) ? map[data] : null;
            if (m1 != null) {
              m1[sessionData.shift_name] = {
                "time": sessionData.time.getTimeOnly(),
                "count": sessionData.bellCount,
                "isSpecialBell": sessionData.isSpecialBell
              };
              map[data] = m1;
            } else {
              map[data] = {
                sessionData.shift_name: {
                  "time": sessionData.time.getTimeOnly(),
                  "count": sessionData.bellCount,
                  "isSpecialBell": sessionData.isSpecialBell
                }
              };
            }
          }
        }
        sessionData.weekdays = weekDayList;
      }
    }
    widget.onSave(map, _data);
  }

  Widget SessionDataWidget(SessionData _data, int index) {
    Widget calWidget;
    if ((!_data.weekdays.contains("Sunday") &&
        !_data.weekdays.contains("Monday") &&
        !_data.weekdays.contains("Tuesday") &&
        !_data.weekdays.contains("Wednesday") &&
        !_data.weekdays.contains("Thursday") &&
        !_data.weekdays.contains("Friday") &&
        !_data.weekdays.contains("Saturday"))) {
      calWidget = Text(_data.weekdays.isNotEmpty ? _data.weekdays[0] : "",
          style: TextStyles().black12Normal);
    } else {
      calWidget = Row(
        children: [
          if (_data.weekdays.contains("Sunday")) WeekWidget('Sun', _data),
          if (_data.weekdays.contains("Monday")) WeekWidget('Mon', _data),
          if (_data.weekdays.contains("Tuesday")) WeekWidget('Tue', _data),
          if (_data.weekdays.contains("Wednesday")) WeekWidget('Wed', _data),
          if (_data.weekdays.contains("Thursday")) WeekWidget('Thu', _data),
          if (_data.weekdays.contains("Friday")) WeekWidget('Fri', _data),
          if (_data.weekdays.contains("Saturday")) WeekWidget('Sat', _data),
        ],
      );
    }

    Widget checkBoxWidget = InkWell(
      // overlayColor: Colors.transparent,
      onTap: () {
        setState(() {
          _data.isSelected = !_data.isSelected;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(right: 1.h),
        child: Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor,
                  blurRadius: 0.1.h,
                ),
              ],
              shape: BoxShape.circle,
              color: _data.isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.white),
          child: Icon(
            Icons.check,
            size: 4.h,
            color: Colors.white,
          ),
        ),
      ),
    );
    Widget timeWidget = Text(
      '${_data.time.getAmPmTime()}',
      style: TextStyles.theme22Bold(context),
    );
    Widget shiftNameWidget = Expanded(
      child: Text(
        '${_data.shift_name}',
        style: TextStyles.black14Normal,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    Widget syncWidget = Wrap(
      direction: Axis.horizontal,
      children: [
        _data.isSynced
            ? Icon(
                Icons.check_circle_rounded,
                size: 2.h,
                color: Colors.green,
              )
            : Icon(
                Icons.error,
                size: 2.h,
                color: Colors.red,
              ),
      ],
    );
    return InkWell(
      onLongPress: () {
        CanDelete = true;
        setState(() {});
        setValueToController();
        setState(() {});
      },
      onTap: () async {
        SessionData data = await Navigators.push(
            context, AddSessionTime(data: _data, dataList: this._data));
        if (data != null) {
          _data = data;
          this._data.removeAt(index);
          this._data.insert(index, data);
          this._data.sort((a,b)=>a.time.compareTo(b.time));
          setState(() {});
          saveDataToServer();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
            color: _data.isSpecialBell == 1
                ? Colors.blueGrey[300]
                : Color(0xffE0E0E0),
            border: Border(
                left: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.h))),
        child: ListTile(
          // key: _key,
          contentPadding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.h),
          leading: (CanDelete) ? checkBoxWidget : null,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: timeWidget,
                    onTap: () async {
                      final TimeOfDay newTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_data.time),
                      );

                      _data.time = new DateTime(
                          _data.time.year,
                          _data.time.month,
                          _data.time.day,
                          newTime.hour,
                          newTime.minute);
                      // _data.tempDate.hour=newTime.hour;
                      saveDataToServer();
                    },
                  ),
                  Text(
                    _data.bellCount > 1
                        ? '${_data.bellCount} Bells'
                        : '${_data.bellCount} Bell',
                    style: TextStyles().black12Normal,
                  ),
                ],
              ),
              SizedBox(
                width: 1.h,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      // direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        shiftNameWidget,
                        syncWidget,
                      ],
                    ),
                    Align(alignment: Alignment.topLeft, child: calWidget),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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

  void deleteDataToServer(
      List<List<String>> deletedWeekDays, List<int> itemDel) async {
    Map<String, dynamic> map = {};

    for (SessionData sessionData in _data) {
      if (sessionData.weekdays.isEmpty) {
        Map<String, dynamic> m1 = {};
        m1[sessionData.shift_name] = {
          "time": sessionData.time.getTimeOnly(),
          "count": sessionData.bellCount
        };
        String onceDate = sessionData.time.getOnceDate();
        map[onceDate] = m1;
      } else {
        for (String data in sessionData.weekdays) {
          Map<String, dynamic> m1 = map.containsKey(data) ? map[data] : null;
          if (m1 != null) {
            m1[sessionData.shift_name] = {
              "time": sessionData.time.getTimeOnly(),
              "count": sessionData.bellCount
            };
            map[data] = m1;
          } else {
            map[data] = {
              sessionData.shift_name: {
                "time": sessionData.time.getTimeOnly(),
                "count": sessionData.bellCount
              }
            };
          }
        }
      }
    }
    for (List<String> weekdays in deletedWeekDays) {
      for (String week in weekdays) {
        if (!map.containsKey(week)) {
          map[week] = {};
        }
      }
    }
    widget.onDelete(map, itemDel);
  }
}

class WeekWidget extends StatelessWidget {
  String weekday;
  SessionData _data;

  WeekWidget(this.weekday, this._data);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.5.h),
          child: Text(
            weekday,
            style: GoogleFonts.getFont(
              "Poppins",
              textStyle: TextStyle(
                  fontSize: 8.sp,
                  color: _data.isSpecialBell == 1
                      ? Theme.of(context).primaryColor
                      : Color(0xff717171)),
            ),
            maxLines: 1,
          )),
    );
  }
}
